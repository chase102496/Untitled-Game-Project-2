extends Node

func heal(target, amt : int):
	if target == Global.player:
		target.my_component_health.heal(amt)
	elif target.classification == Battle.classification.DREAMKIN:
		if target is Node:
			target.my_component_health.heal(amt)
		elif target is Object:
			target.heal(amt)
	else:
		push_error("Could not find matching type to apply heal to")
