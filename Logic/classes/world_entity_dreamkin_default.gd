class_name world_entity_dreamkin_default
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_follow
@export var my_component_ability : component_ability

##Default vars
var type : Dictionary = Battle.type.BALANCE
var options_world := {
	"Recall" : Callable(Global.player.my_component_party,"recall_inst").bind(self),
	}
var options_battle : Dictionary = {}

##If we are being created, not from a party object but from nothing
func init(my_parent : Node, my_position : Vector3):
	my_parent.add_child.call_deferred(self)
	global_translate.call_deferred(my_position)
	return self

func _ready():
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_abilities.append(abil.ability_solar_flare.new(self,1,1.0))
	my_component_ability.current_status_effects.add_passive(abil.status_immunity.new(self,Battle.type.CHAOS))

##If we are being summoned from a party object, load all stats from party_dreamkin object, which we get from get_dreamkin_data_dictionary()
func party_summon(data : Object):
	Global.player.get_parent().add_child(self)
	
	set_deferred("unique_id",data.unique_id)
	set_deferred("name",data.name)
	set_deferred("classification",data.classification)
	set_deferred("global_position",Global.player.global_position+Vector3(randf_range(0.2,0.8),0,randf_range(0.2,0.8)))
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
	
	data.unique_id = unique_id
	data.name = name
	data.classification = classification
	data.global_position = global_position
	data.glossary = glossary
	data.type = type
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	data.my_abilities = my_component_ability.get_data_ability_all()
	data.current_status_effects = my_component_ability.get_data_status_all()
	
	return data
