class_name battle_entity_dreamkin_default
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control
#@export_group("Components")
#@export var my_component_input_controller : Node

func _ready() -> void:
	#name = str(name," ",randi())
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_abilities.append(abil.ability_solar_flare.new(self,1,0.4,1))
	abil.current_status_effects.add_passive(abil.status_immunity.new(self,Battle.type.CHAOS))
