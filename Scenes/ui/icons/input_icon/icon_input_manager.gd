extends Node

@export var input_action : String = "interact"
@export var animation_name : String = "press"
@export var prompt_label : Label
@export var my_component_input_animation_gizmo : component_input_animation_gizmo
@export var inner_container : Container

func _ready():
	update_pivot()
	prompt_label.resized.connect(_on_resized)
	if input_action:
		
		## Setting listen event
		my_component_input_animation_gizmo.input_action = input_action
		
		## Setting animation
		my_component_input_animation_gizmo.animation_name = animation_name
		
		prompt_label.text = Global.input_action_to_keycode_string(input_action)

func update_pivot():
	inner_container.pivot_offset = inner_container.size / 2

	# If the text changes dynamically, ensure to call `update_pivot`
func _on_resized():
	update_pivot()
