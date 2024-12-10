class_name component_respawn_handler
extends Node

var safe_location : Vector3

func _ready() -> void:
	safe_location = owner.global_position

func respawn_safe():
	#disable player
	#do not re-load level
	#transition out
	#heal, vis, and loc change
	#transition in
	pass

func respawn_full():
	#disable player
	#re-load level and save file and do not save anything
	pass
