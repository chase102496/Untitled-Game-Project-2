shader_type spatial;

uniform sampler2D texture_albedo; // Define the texture
uniform vec4 albedo_color = vec4(1.0, 1.0, 1.0, 1.0); // Hint for color picker
uniform float blend_sharpness : hint_range(0.1, 10.0) = 2.0; // Hint for slider in UI

void fragment() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // Transform to world space
    vec3 normal = normalize(NORMAL); // Normalize surface normal
    
    // Triplanar UVs for X, Y, Z projections
    vec2 uv_x = world_pos.yz;
    vec2 uv_y = world_pos.zx;
    vec2 uv_z = world_pos.xy;

    // Sample the texture for each axis projection
    vec4 tex_x = texture(texture_albedo, uv_x);
    vec4 tex_y = texture(texture_albedo, uv_y);
    vec4 tex_z = texture(texture_albedo, uv_z);

    // Calculate blending weights based on normal direction
    vec3 weights = pow(abs(normal), vec3(blend_sharpness));
    weights /= (weights.x + weights.y + weights.z); // Normalize weights

    // Blend the textures
    vec4 blended_texture = tex_x * weights.x + tex_y * weights.y + tex_z * weights.z;

    // Output final albedo color
    ALBEDO = blended_texture.rgb * albedo_color.rgb;
    ALPHA = albedo_color.a; // Optional for transparency
}
