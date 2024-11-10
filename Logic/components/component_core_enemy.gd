extends Node

func initialize():
	owner.name = str(owner.name," ",randi_range(0,99))
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(owner)
	]
	
