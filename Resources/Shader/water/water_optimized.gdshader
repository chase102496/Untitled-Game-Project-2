shader_type spatial;
render_mode depth_draw_always;

#define FRESNEL
#define PLAYER_WAVES
#define DISPLACEMENT

group_uniforms color;
uniform vec3 absorption_color : source_color = vec3(1.0, 0.35, 0.0);
#ifdef FRESNEL
uniform float fresnel_radius : hint_range(0.0, 6.0, 0.01) = 2.0;
uniform vec3 fresnel_color : source_color = vec3(0.0, 0.57, 0.72);
#endif
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.25;
// Depth adjustment
uniform float depth_distance : hint_range(0.0, 50.0, 0.1) = 25.0;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 4.5;

#ifdef DISPLACEMENT
group_uniforms displacement;
uniform float displacement_strength : hint_range(0.0, 5.0, 0.1) = 0.3;
uniform float displacement_scroll_speed : hint_range(0.0, 1.0, 0.001) = 0.1;
uniform vec2 displacement_scroll_offset = vec2 (-0.2, 0.3);
uniform float displacement_scale_offset = 0.5;
uniform vec2 displacement_scale = vec2(0.04);
uniform sampler2D displacement_texture : hint_default_black, repeat_enable;
#endif

group_uniforms edge;
uniform float edge_thickness : hint_range(0.0, 1.0, 0.001) = 0.3;
uniform float edge_speed : hint_range(0.0, 1.0, 0.001) = 0.35;
uniform vec2 edge_noise_scale = vec2(0.4);
uniform sampler2D edge_noise : repeat_enable;
uniform sampler2D edge_ramp : repeat_disable;

#ifdef PLAYER_WAVES
group_uniforms player;
uniform float influence_size : hint_range(0.0, 4.0, 0.1) = 1.0;
uniform float player_wave_frequenzy : hint_range(0.0, 20.0, 0.1) = 10.0;
uniform float player_wave_speed : hint_range(0.0, 10.0, 0.1) = 5.0;
#endif

group_uniforms caustics;
uniform sampler2D caustics_texture : hint_default_black, repeat_enable;
uniform float caustic_size : hint_range(0.0, 6.0, 0.01) = 2.0;
uniform float caustic_strength : hint_range(0.0, 1.0, 0.01) = 0.08;
uniform float caustic_scroll_speed : hint_range(0.0, 1.0, 0.01) = 0.1;

group_uniforms normal_map;
uniform float refraction_strength : hint_range(0.0, 4.0, 0.01) = 1.25;
uniform float normal_map_strength : hint_range(0.0, 4.0, 0.01) = 1.0;
uniform float scroll_speed : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform vec2 scroll_offset = vec2(0.1, -0.3);
uniform float scale_offset = 0.5;
uniform vec2 normal_map_scale = vec2(0.1);
uniform sampler2D normal_map : hint_normal, filter_linear_mipmap;

// Hidden Uniforms
global uniform float wind_intensity; // Global shader parameter between 0.0 and 1.0
global uniform vec3 wind_direction;
#ifdef PLAYER_WAVES
global uniform vec3 player_position;
#endif
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap, repeat_enable;
uniform sampler2D depth_texture: hint_depth_texture, filter_linear_mipmap;

varying vec3 global_position;

#ifdef FRESNEL
float fresnel(vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), fresnel_radius);
}
#endif

vec2 refract_uv(vec2 uv, vec3 normal, float depth){
	float strength1 = refraction_strength * depth;
	uv += fma(strength1, length(normal), strength1 * -1.2);
	return uv;
}

void vertex() {
	global_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	#ifdef DISPLACEMENT
	float time = TIME * displacement_scroll_speed * fma(wind_intensity, 0.7, 0.3);
	float displace1 = texture(displacement_texture, fma(global_position.xz, displacement_scale, time * -wind_direction.xz)).r;
	float displace2 = texture(displacement_texture, fma(global_position.xz, displacement_scale * displacement_scale_offset, time * (-wind_direction.xz + displacement_scroll_offset))).r;
	float displacement_mixed = mix(displace1, displace2, 0.4);
	float offset = fma(displacement_mixed, 2.0, -1.0) * displacement_strength;
	VERTEX.y += offset;
	global_position.y += offset;
	#endif
}

void fragment() {
	vec3 opposing_color = vec3(1.0) - absorption_color.rgb;
	vec3 normalized_wind_direction = normalize(wind_direction);
	float wind_intens_factor = fma(wind_intensity, 0.7, 0.3);
	#ifdef FRESNEL
	float fresnel_value = fresnel(NORMAL, VIEW);
	#endif
	float time_factor = TIME * scroll_speed * wind_intens_factor;
	vec3 n1 = texture(normal_map, fma(global_position.xz, normal_map_scale, time_factor * -normalized_wind_direction.xz)).xyz;
	vec3 n2 = texture(normal_map, fma(global_position.xz, normal_map_scale * scale_offset, time_factor * 0.8 * (-normalized_wind_direction.xz + scroll_offset))).xyz;
	NORMAL_MAP = mix(n1, n2, 0.5);
	NORMAL_MAP_DEPTH = normal_map_strength;

	float lod = textureQueryLod(screen_texture, SCREEN_UV).y;
	float depth_tex = textureLod(depth_texture, SCREEN_UV, lod).r;

	vec3 ndc = vec3(fma(SCREEN_UV, vec2(2.0), vec2(-1.0)), depth_tex);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertey_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float relative_depth = vertey_y - depth_texture_y;

	// Simplified Caustic Effects
	vec2 caustic_uv = global_position.xz * caustic_size + vec2(TIME * caustic_scroll_speed);
	float caustic_value = texture(caustics_texture, caustic_uv).r * caustic_strength;

	// Create Edge caused by other Objects
	float edge_blend = clamp(relative_depth / -edge_thickness + 1.0, 0.0, 1.0);
	vec2 edge_noise_uv = global_position.xz * edge_noise_scale * fma(normalized_wind_direction.xz, vec2(0.5), vec2(0.5));
	edge_noise_uv = fma(-normalized_wind_direction.xz * TIME * edge_speed, vec2(wind_intens_factor), edge_noise_uv);
	float edge_noise_sample = texture(edge_noise, edge_noise_uv).r;
	float edge_mask = normalize(texture(edge_ramp, vec2(edge_noise_sample * fma(edge_blend, -1., 1.))).r);

	// Create Ripples caused by player
	float player_effect_mask = 0.0;
	#ifdef PLAYER_WAVES
	vec3 player_relative = vec3(global_position - player_position);
	float player_height = smoothstep(1.0, 0.0, abs(player_relative.y));
	float player_position_factor = smoothstep(influence_size, 0.0, length(player_relative.xz));
	float player_waves = pow( fma( sin(fma(player_position_factor, player_wave_frequenzy, TIME * player_wave_speed)), 0.5, 0.5), 6.0);
	float wave_distort = texture(edge_ramp, vec2(player_waves * (edge_noise_sample + 0.2) * player_position_factor * player_height)).x;
	player_effect_mask = clamp(normalize(fma(wave_distort, -1.0, 0.4)), 0.0, 1.0);
	#endif

	// combine Edge Mask with Player Ripples
	float ripple_mask = clamp(fma(edge_mask, edge_blend, player_effect_mask), 0.0, 1.0);

	// Calculate Fragment Depth
	vec4 clip_pos = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	clip_pos.xyz /= clip_pos.w;
	DEPTH = clip_pos.z;
	// Refract UV
	vec2 refracted_uv = refract_uv(SCREEN_UV, NORMAL_MAP, sqrt(DEPTH));

	vec3 screen;
	float depth_blend;
	float refracted_depth_tex = textureLod(depth_texture, refracted_uv, lod).x;
	ndc.z = refracted_depth_tex;
	world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float refracted_depth_texture_y = world.y / world.w;
	float depth_test = vertey_y - refracted_depth_texture_y;

	vec2 fruv = abs(floor(refracted_uv));
	bool out_of_bounds = fruv.x + fruv.y < 0.001;

	if (depth_test > 0.0 && out_of_bounds) {
		screen = textureLod(screen_texture, refracted_uv, lod).rgb * 0.9;
		depth_blend = clamp(depth_test / depth_distance, 0.0, 1.0);
		depth_blend = fma(exp(-depth_blend * beers_law), -1.0, 1.0);
	} else {
		screen = textureLod(screen_texture, SCREEN_UV, lod).rgb * 0.9;
		depth_blend = clamp(relative_depth / depth_distance, 0.0, 1.0);
		depth_blend = fma(exp(-depth_blend * beers_law), -1.0, 1.0);
	}

	vec3 color = clamp(screen - absorption_color.rgb * depth_blend, vec3(0.0), vec3(1.0)); // Absorb Screen Color
	color = mix(color, opposing_color, depth_blend * depth_blend); // Apply depth color
	#ifdef FRESNEL
	color = mix(color, fresnel_color, fresnel_value); // Apply fresnel color
	#endif
	color = clamp(color + caustic_value, vec3(0.0), vec3(1.0)); // Simplified Caustics
	color = mix(color, vec3(0.98), ripple_mask); // Apply Ripples
	ALBEDO = color;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
