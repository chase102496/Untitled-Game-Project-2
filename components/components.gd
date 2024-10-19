extends Node

@warning_ignore("unused_signal")
signal input_controller(input_name, param1)
@warning_ignore("unused_signal")
signal animation_controller(anim_name)

signal input_controller_direction(dir)

@warning_ignore("shadowed_global_identifier")
func get_state_chart_node(str):
	return(get_node(str(owner.get_path(),str)))
