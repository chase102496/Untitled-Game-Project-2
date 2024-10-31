class_name component_vis
extends Node

@export var max_vis : int = 6
var vis : int

func _ready() -> void:
	vis = max_vis

func siphon(amt): #removes vis
	print_debug(vis," MP -> ",vis - amt," MP")
	vis -= amt
