class_name world_entity_dreamkin_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow

func _ready():
	#name = str(name," ",randi())
	pass
