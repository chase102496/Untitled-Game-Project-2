extends Node

## Similar to classification, but more exhaustive
func evaluate_class_type(input) -> RefCounted:
	
	## World
	if input is world_entity_player:
		return world_entity_player
	elif input is world_entity_dreamkin:
		return world_entity_dreamkin
	## Battle
	elif input is battle_entity_player:
		return battle_entity_player
	elif input is battle_entity_dreamkin:
		return battle_entity_dreamkin
	elif input is component_party.party_dreamkin:
		return component_party.party_dreamkin
	elif input is battle_entity_enemy:
		return battle_entity_enemy
	## Ability
	elif input is component_ability.ability:
		return component_ability.ability
	elif input is component_world_ability.world_ability:
		return component_world_ability.world_ability
	## Item
	elif input is component_inventory.item:
		return component_inventory.item
	else:
		return
	
	#if "classification" in input:
		#if input.classification == Battle.classification.PLAYER:
			#return entity_type.PLAYER
		#if input.classification == Battle.classification.DREAMKIN:
			#if input is Node:
				#return entity_type.SUMMONED_DREAMKIN
			#elif input is component_party.party_dreamkin:
				#return entity_type.PARTY_DREAMKIN
		#elif input.classification == Battle.classification.ITEM:
			#return entity_type.INVENTORY_ITEM
	#else:
		#return entity_type.NOT_FOUND

## Restores party and Lumia to full health and vis
func restore_all():
	
	for member in Global.player.my_component_party.get_hybrid_data_all():
		change_vis(member,get_root_vis(member).max_vis)
		change_health(member,get_root_health(member).max_health)
	
	change_health(Global.player,Global.player.my_component_health.max_health)
	change_vis(Global.player,Global.player.my_component_vis.max_vis)

##
func change_health(target, amt : int):
	match evaluate_class_type(target):
		world_entity_player, battle_entity_player, world_entity_dreamkin, battle_entity_dreamkin:
			target.my_component_health.change(amt)
		component_party.party_dreamkin:
			target.change_health(amt)
		_:
			push_error("Could not find matching type to apply change_health to - ",target)

##
func change_vis(target, amt : int):
	match evaluate_class_type(target):
		world_entity_player, battle_entity_player, world_entity_dreamkin, battle_entity_dreamkin:
			target.my_component_vis.change(amt)
		component_party.party_dreamkin:
			target.change_vis(amt)
		_:
			push_error("Could not find matching type to apply change_vis to - ",target)

##
func get_root_health(target):
	match evaluate_class_type(target):
		world_entity_player, battle_entity_player, world_entity_dreamkin, battle_entity_dreamkin:
			return target.my_component_health
		component_party.party_dreamkin:
			return target
		_:
			push_error("Could not find matching type to get root of health - ",target)

##
func get_root_vis(target):
	match evaluate_class_type(target):
		world_entity_player, battle_entity_player, world_entity_dreamkin, battle_entity_dreamkin:
			return target.my_component_vis
		component_party.party_dreamkin:
			return target
		_:
			push_error("Could not find matching type to get root of vis - ",target)

##
func get_root_abilities(target):
	match evaluate_class_type(target):
		world_entity_player, battle_entity_player, world_entity_dreamkin, battle_entity_dreamkin:
			return target.my_component_ability.get_abilities()
		component_party.party_dreamkin:
			return target.my_abilities
		_:
			push_error("Could not find matching type to get root of abilities - ",target)
