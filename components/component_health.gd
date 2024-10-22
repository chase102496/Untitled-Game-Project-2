class_name component_health
extends Node

@export var max_health : int = 6
var health : int

func _ready() -> void:
	health = max_health

func damage(amt):
	
	health -= amt
	
	owner.anim_tree.get("parameters/playback").travel("Squish")
	
	if health <= 0:
		owner.state_chart.send_event("on_death")

#maybe later add a function to constantly check if we have 0 hp and delete us
