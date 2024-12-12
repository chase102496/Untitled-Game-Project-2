shader_type fog;

uniform float speed : hint_range(0.0, 0.3, 0.001);
uniform vec3 color : source_color;
uniform float density : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform sampler2D noise_tex : repeat_enable;
uniform float noise_scale : hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float falloff : hint_range(0.0, 30.0, 0.1) = 3.0;

float Noise(vec2 uv) {
	return texture(noise_tex, uv).r;
}

void fog() {
	vec2 uv = UVW.xz * noise_scale + vec2(TIME * speed, 0);
	float noise = Noise(uv);
	DENSITY = mix(1.0, noise, UVW.y * falloff) * density;
	ALBEDO = color;
}
