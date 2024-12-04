extends Node

enum entity_type {
	PLAYER,
	SUMMONED_DREAMKIN,
	PARTY_DREAMKIN,
	INVENTORY_ITEM,
	NOT_FOUND
}

## Similar to classification, but more exhaustive
func evaluate_entity_type(input):
	if "classification" in input:
		if input.classification == Battle.classification.PLAYER:
			return entity_type.PLAYER
		if input.classification == Battle.classification.DREAMKIN:
			if input is Node:
				return entity_type.SUMMONED_DREAMKIN
			elif input is Object:
				return entity_type.PARTY_DREAMKIN
		elif input.classification == Battle.classification.ITEM:
			return entity_type.INVENTORY_ITEM
	else:
		return entity_type.NOT_FOUND

##
func change_health(target, amt : int):
	match evaluate_entity_type(target):
		entity_type.PLAYER, entity_type.SUMMONED_DREAMKIN:
			target.my_component_health.change(amt)
		entity_type.PARTY_DREAMKIN:
			target.change_health(amt)
		entity_type.NOT_FOUND:
			push_error("Could not find matching type to apply change_health to - ",target)

##
func change_vis(target, amt : int):
	match evaluate_entity_type(target):
		entity_type.PLAYER, entity_type.SUMMONED_DREAMKIN:
			target.my_component_vis.change(amt)
		entity_type.PARTY_DREAMKIN:
			target.change_vis(amt)
		entity_type.NOT_FOUND:
			push_error("Could not find matching type to apply change_vis to - ",target)

##
func get_root_health(target):
	match evaluate_entity_type(target):
		entity_type.PLAYER, entity_type.SUMMONED_DREAMKIN:
			return target.my_component_health
		entity_type.PARTY_DREAMKIN:
			return target
		entity_type.NOT_FOUND:
			push_error("Could not find matching type to get root of health - ",target)

##
func get_root_vis(target):
	match evaluate_entity_type(target):
		entity_type.PLAYER, entity_type.SUMMONED_DREAMKIN:
			return target.my_component_vis
		entity_type.PARTY_DREAMKIN:
			return target
		entity_type.NOT_FOUND:
			push_error("Could not find matching type to get root of vis - ",target)

##
func get_root_abilities(target):
	match evaluate_entity_type(target):
		entity_type.PLAYER, entity_type.SUMMONED_DREAMKIN:
			return target.my_component_ability.my_abilities
		entity_type.PARTY_DREAMKIN:
			return target.my_abilities
		entity_type.NOT_FOUND:
			push_error("Could not find matching type to get root of abilities - ",target)
		_:
			push_error("Could not find matching type to get root of abilities - ",target)
