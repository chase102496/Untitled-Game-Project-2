class_name world_entity_dreamkin_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow
@export var my_component_ability : component_ability

func init(my_parent : Node, my_position : Vector3, initial_state : String = ""):
	my_parent.add_child.call_deferred(self)
	global_translate.call_deferred(my_position)
	if initial_state != "":
		set_deferred("state_init_override",initial_state)
	return self

func _ready():
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
