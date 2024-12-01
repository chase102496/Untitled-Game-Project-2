extends Node

func change_health(target, amt : int):
	if target == Global.player:
		target.my_component_health.change(amt)
	elif target.classification == Battle.classification.DREAMKIN:
		if target is Node:
			target.my_component_health.change(amt)
		elif target is Object:
			target.change_health(amt)
	else:
		push_error("Could not find matching type to apply heal to")

func change_vis(target, amt : int):
	if target == Global.player:
		target.my_component_vis.change(amt)
	elif target.classification == Battle.classification.DREAMKIN:
		if target is Node:
			target.my_component_vis.change(amt)
		elif target is Object:
			target.change_vis(amt)
	else:
		push_error("Could not find matching type to apply siphon to")
