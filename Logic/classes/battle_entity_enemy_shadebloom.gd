class_name battle_entity_enemy_shadebloom
extends battle_entity_enemy_default

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_spook.new(self,1,0.3,0))
	abil.current_status_effects.add_passive(abil.status_thorns.new(self,2))
