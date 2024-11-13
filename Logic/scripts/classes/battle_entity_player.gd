class_name battle_entity_player
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control
#@export_group("Components")
#@export var my_component_input_controller : Node

func _ready():
	#name = str(name," ",randi())
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_abilities.append(abil.ability_heartstitch.new(self))
