class_name world_entity_interact
extends Node3D

signal enter(source : Node)
signal exit(source : Node)
signal interact(source : Node)

@export var my_owner : Node3D

## --- Functions --- ##

#func _ready() -> void:
	#enter.connect(_on_enter)
	#exit.connect(_on_exit)
	#interact.connect(_on_interact)

#func _on_enter(source : Node):
	#print_debug("INTERACT ENTITY EVENT: ",source.name," entered ",my_owner.name)

#func _on_exit(source : Node):
	#print_debug("INTERACT ENTITY EVENT: ",source.name," exited ",my_owner.name)

#func _on_interact(source : Node):
	#print_debug("INTERACT ENTITY EVENT: ",source.name," interacted with ",my_owner.name)
