extends Node

func get_state_chart_node(str):
	return(get_node(str(owner.get_path(),str)))

func state_verify():
	#If our current running state is equal to what is actually the state or substate
	if get_parent() in [owner.state_subchart._active_state._active_state,owner.state_subchart._active_state]:
		return true
	else:
		return false
