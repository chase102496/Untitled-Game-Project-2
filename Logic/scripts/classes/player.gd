class_name player
extends entity

func _ready():
	#name = str(name," ",randi())
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_abilities.append(abil.ability_heartstitch.new(self))
