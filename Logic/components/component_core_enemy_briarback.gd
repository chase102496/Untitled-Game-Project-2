extends Node

func initialize():
	owner.name = str(owner.name," ",randi_range(0,99))
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_spook.new(owner)
	]
	#abil.current_status_effects.add_passive(abil.status_thorns.new(owner,1))
	#abil.current_status_effects.add_passive(abil.status_ethereal.new(owner))
	abil.current_status_effects.add_passive(abil.status_regrowth.new(owner))
