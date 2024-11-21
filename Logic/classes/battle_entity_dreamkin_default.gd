class_name battle_entity_dreamkin_default
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control

func init(my_parent : Node, my_position : Vector3, initial_state : String = ""):
	my_parent.add_child.call_deferred(self)
	global_translate.call_deferred(my_position)
	if initial_state != "":
		set_deferred("state_init_override",initial_state)
	return self

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	#var abil = my_component_ability
	#abil.my_abilities.append(abil.ability_tackle.new(self))
	#abil.my_abilities.append(abil.ability_solar_flare.new(self,1,0.4,1))
	#abil.current_status_effects.add_passive(abil.status_immunity.new(self,Battle.type.CHAOS))
