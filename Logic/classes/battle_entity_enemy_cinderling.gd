class_name battle_entity_enemy_cinderling
extends battle_entity_enemy_default

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_solar_flare.new(self,2,0.4,0))
	abil.my_status.add_passive(abil.status_immunity.new(self,Battle.type.CHAOS))
	abil.my_status.add_passive(abil.status_weakness.new(self,Battle.type.VOID))
