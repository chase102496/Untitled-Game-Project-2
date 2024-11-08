extends Node

func initialize():
	#owner.name = str(name," ",randi())
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(self),
		abil.ability_solar_flare.new(self),
		abil.ability.new(self),
		abil.ability.new(self)
		]
	owner.animations.tree.active = true
