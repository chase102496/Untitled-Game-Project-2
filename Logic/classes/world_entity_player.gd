class_name world_entity_player
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual

func _ready():
	#name = str(name," ",randi())
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
