extends Node

func initialize():
	owner.name = str(owner.name," ",randi())
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_spook.new(owner)
	]
