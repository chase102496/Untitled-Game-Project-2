class_name component_input_animation_gizmo
extends Node

@export var input_action : String = "interact"
@export var animation_name : String = "press"
@export var animation_player : AnimationPlayer

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(input_action):
		animation_player.play(animation_name)
