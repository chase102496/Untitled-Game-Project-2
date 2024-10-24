class_name component_vis
extends Node

@export var max_vis : int = 6
var vis : int

func _ready() -> void:
	vis = max_vis



func remove(amt):
	
	print_debug("Target vis before:", vis)
	
	vis -= amt
	
	print_debug("Target vis after:", vis)
	
	if vis <= 0:
		owner.state_chart.send_event("on_death")

#maybe later add a function to constantly check if we have 0 hp and delete us
