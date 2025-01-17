shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * vec4(1.0, 1.0, 1.0, COLOR.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
