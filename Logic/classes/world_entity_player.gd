class_name world_entity_player
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party

func _ready():
	#name = str(name," ",randi())
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	my_component_party.add(world_entity_dreamkin_default.create(global_position,owner))
	my_component_party.add(world_entity_dreamkin_default.create(global_position,owner))
