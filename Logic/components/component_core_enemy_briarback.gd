extends Node

func initialize():
	owner.name = str(owner.name," ",randi_range(0,99))
	var abil = owner.my_component_ability
	abil.add_ability(abil.ability_spook.new())
	#abil.my_status.add_passive(abil.status_thorns.new(owner,1))
	#abil.my_status.add_passive(abil.status_ethereal.new(owner))
	abil.my_status.add_passive(abil.status_regrowth.new())
