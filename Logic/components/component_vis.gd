class_name component_vis
extends Node

@export var max_vis : int = 6
var vis : int

func _ready() -> void:
	vis = max_vis

func restore(amt : int):
	var old_vis = vis
	vis = clamp(vis + amt,0,max_vis) #TODO Maybe make an overflow mechanic good/bad?
	print_debug(old_vis," MP -> ",vis," MP")

func siphon(amt : int):
	var old_vis = vis
	
	if vis > 0:
		vis -= amt
	else:
		owner.my_component_health.damage(amt) #Do damage if we're out of vis
	
	print_debug(old_vis," MP -> ",vis," MP")
