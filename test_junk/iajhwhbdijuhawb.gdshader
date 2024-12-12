shader_type spatial;

uniform sampler2D noise_texture; // The noise texture
uniform float pan_speed_x : hint_range(-1.0, 1.0); // Speed of panning in X
uniform float pan_speed_y : hint_range(-1.0, 1.0); // Speed of panning in Y
uniform float intensity : hint_range(0.0, 1.0);    // Intensity of the fog effect
uniform vec4 fog_color : source_color;            // Color of the fog

void fragment() {
    // Get world position
    vec3 world_pos = WORLD_POSITION;

    // Calculate UV coordinates for noise texture
    vec2 uv = vec2(world_pos.x, world_pos.z) * 0.1; // Scale UVs for the texture
    uv += vec2(TIME * pan_speed_x, TIME * pan_speed_y); // Pan the UVs over time

    // Sample the noise texture
    float noise_value = texture(noise_texture, uv).r;

    // Adjust fog intensity
    float fog_amount = noise_value * intensity;

    // Blend fog color with scene
    ALBEDO = mix(ALBEDO, fog_color.rgb, fog_amount);
    ALPHA = fog_amount; // Optional: Adjust alpha for transparency
}