class_name battle_entity_enemy_default
extends battle_entity_default

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(self)
	]
