class_name world_entity_dreamkin_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow

static var my_scene : PackedScene = preload("res://Scenes/characters/world_entity_dreamkin_default.tscn")

static func create(my_position : Vector3, my_parent : Node) -> world_entity_dreamkin_default:
	var inst = my_scene.instantiate()
	my_parent.add_child.call_deferred(inst)
	inst.global_translate.call_deferred(my_position)
	#abilities
	#health
	#vis
	return inst

func _ready():
	
	#name = str(name," ",randi())
	pass
