extends Node

signal input_controller(input_name, param1)
signal animation_controller(anim_name)

func get_state_chart_node(str):
	return(get_node(str(owner.get_path(),str)))
