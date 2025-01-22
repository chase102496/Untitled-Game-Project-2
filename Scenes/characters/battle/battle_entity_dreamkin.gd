class_name battle_entity_dreamkin
extends battle_entity

@export_group("Modules")
@export var my_battle_gui : Control

## Placeholders until we fix this later
var type
##
var icon : PackedScene

func init(my_parent : Node, my_position : Vector3) -> battle_entity_dreamkin:
	my_parent.add_child.call_deferred(self)
	global_translate.call_deferred(my_position)
	return self

## Checks if we are eligible to go into battle
func select_validate():
	if my_component_health.health > 0:
		return true
	else:
		print_debug("!cannot be summoned!")

##If we are being summoned, load all stats from party_dreamkin object, which we get from get_dreamkin_data_dictionary()
func party_summon(data : Object):
	Global.player.add_sibling(self)
	set_deferred("global_position",Global.player.global_position)
	
	set_deferred("unique_id",data.unique_id)
	set_deferred("name",data.name)
	set_deferred("classification",data.classification)
	set_deferred("glossary",data.glossary)
	set_deferred("type",data.type)
	set_deferred("icon",data.icon)
	my_component_health.set_deferred("health",data.health)
	my_component_health.set_deferred("max_health",data.max_health)
	my_component_vis.set_deferred("vis",data.vis)
	my_component_vis.set_deferred("max_vis",data.max_vis)
	my_component_ability.set_data_ability_all.call_deferred(self,data.my_abilities)
	my_component_ability.set_data_status_all.call_deferred(self,data.my_status)
	
	return self

#If someone is requesting data to save about us, give it all stats to use for party_summon()
func get_dreamkin_data_dictionary():
	var data : Dictionary = {}
	data.unique_id = unique_id
	data.name = name
	data.classification = classification
	data.glossary = glossary
	data.type = type
	data.icon = icon
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	data.my_abilities = my_component_ability.get_data_ability_all()
	data.my_status = my_component_ability.get_data_status_all()
	
	return data
