extends Node

func initialize():
	#owner.name = str(name," ",randi())
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(owner),
		abil.ability_solar_flare.new(owner),
		abil.ability.new(owner),
		abil.ability.new(owner)
		]
