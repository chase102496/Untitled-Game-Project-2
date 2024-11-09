extends Node

func initialize():
	#owner.name = str(name," ",randi())
	Global.player = owner
	Dialogic.preload_timeline("res://timeline.dtl")
	var abil = owner.my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(owner),
		abil.ability_spook.new(owner),
		abil.ability_heartstitch.new(owner),
		abil.ability.new(owner)
		]
