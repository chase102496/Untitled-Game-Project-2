extends Control

@export var textrect : TextureRect

func set_color(col : Color) -> void:
	var gradtext = GradientTexture1D.new()
	var grad = Gradient.new()
	grad.set_color(1,col)
	gradtext.set_gradient(grad)
	textrect.material.set_shader_parameter("gradient_texture",gradtext)
