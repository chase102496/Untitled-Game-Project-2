class_name world_entity_dreamkin_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow
@export var my_component_ability : component_ability

static var my_scene : PackedScene = load("res://Scenes/characters/world_entity_dreamkin_default.tscn")

static func create(my_position : Vector3, my_parent : Node) -> world_entity_dreamkin_default:
	var inst = my_scene.instantiate()
	my_parent.add_child.call_deferred(inst)
	inst.global_translate.call_deferred(my_position)

	return inst

func _ready():
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
