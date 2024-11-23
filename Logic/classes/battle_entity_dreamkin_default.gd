class_name battle_entity_dreamkin_default
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control

var type = Battle.type.BALANCE

func init(my_parent : Node, my_position : Vector3, initial_state : String = ""):
	my_parent.add_child.call_deferred(self)
	global_translate.call_deferred(my_position)
	if initial_state != "":
		set_deferred("state_init_override",initial_state)
	return self

## Checks if we are eligible to go into battle
func select_validate():
	if my_component_health.health > 0:
		return true
	else:
		print_debug("!Ineligible for battle!")

##If we are being summoned, load all stats from party_dreamkin object, which we get from get_dreamkin_data_dictionary()
func party_summon(data : Object):
	Global.player.get_parent().add_child(self)
	
	set_deferred("name",data.name)
	set_deferred("global_position",Global.player.global_position)
	set_deferred("glossary",data.glossary)
	set_deferred("type",data.type)
	my_component_health.set_deferred("health",data.health)
	my_component_health.set_deferred("max_health",data.max_health)
	my_component_vis.set_deferred("vis",data.vis)
	my_component_vis.set_deferred("max_vis",data.max_vis)
	my_component_ability.set_data_ability_all.call_deferred(self,data.my_abilities)
	my_component_ability.set_data_status_all.call_deferred(self,data.current_status_effects)
	
	return self

#If someone is requesting data to save about us, give it all stats to use for party_summon()
func get_dreamkin_data_dictionary():
	var data : Dictionary = {}
	
	data.name = name
	data.glossary = glossary
	data.type = type
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	data.my_abilities = my_component_ability.get_data_ability_all()
	data.current_status_effects = my_component_ability.get_data_status_all()
	
	return data

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
