class_name battle_entity_enemy
extends battle_entity

func _ready() -> void:
	if my_component_ability:
		my_component_ability.my_abilities.append(component_ability.ability_tackle.new(self))
