class_name world_entity_npc_default
extends world_entity_default

signal on_interact

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow

func _ready() -> void:
	on_interact.connect(_on_interact)
	
func _on_interact() -> void:
	pass
