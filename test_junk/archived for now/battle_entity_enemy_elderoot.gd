class_name battle_entity_enemy_elderoot
extends battle_entity_enemy_default

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_status.add_passive(abil.status_regrowth.new(self))
	abil.my_status.add_passive(abil.status_weakness.new(self,Battle.type.CHAOS))
