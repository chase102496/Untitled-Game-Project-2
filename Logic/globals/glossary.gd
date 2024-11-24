extends Node

var ability_class : Dictionary = {
	"ability_tackle" : component_ability.ability_tackle,
	"ability_headbutt" : component_ability.ability_headbutt,
	"ability_solar_flare" : component_ability.ability_solar_flare,
	"ability_heartstitch" : component_ability.ability_heartstitch,
	"ability_switchstitch" : component_ability.ability_switchstitch,
	"ability_spook" : component_ability.ability_spook,
	"ability_frigid_core" : component_ability.ability_frigid_core,
}

var status_class : Dictionary = {
	##Normal
	"status_fear" : component_ability.status_fear,
	"status_burn" : component_ability.status_burn,
	"status_freeze" : component_ability.status_freeze,
	##Tethers
	"status_heartstitch" : component_ability.status_heartstitch,
	##Passives
	"status_immunity" : component_ability.status_immunity, #Immune to specific aspect
	"status_weakness" : component_ability.status_weakness, #Weak to specific aspect
	"status_ethereal" : component_ability.status_ethereal, #Immune to all but one aspect
	"status_disabled" : component_ability.status_disabled, #Immune to everything and disabled
	"status_swarm" : component_ability.status_swarm, #Damage based on how many of it are on field
	"status_regrowth" : component_ability.status_regrowth, #Doesn't die unless its kind are all dead aswell
	"status_thorns" : component_ability.status_thorns, #Reflects damage on direct hit
	##abil.current_status_effects.add_passive(abil.status_immunity.new(self,Battle.type.CHAOS))
}

const entity : Dictionary = {
	
	# Players
	"battle_entity_player" : preload("res://Scenes/characters/battle_entity_player.tscn"),
	"world_entity_player" : preload("res://Scenes/characters/world_entity_player.tscn"),
	
	# Dreamkin
	"battle_entity_dreamkin_default" : preload("res://Scenes/characters/battle_entity_dreamkin_default.tscn"),
	"world_entity_dreamkin_default" : preload("res://Scenes/characters/world_entity_dreamkin_default.tscn"),
	#
	"battle_entity_dreamkin_sparx" : preload("res://Scenes/characters/battle_entity_dreamkin_sparx.tscn"),
	# Enemies
	"battle_entity_enemy_default" : preload("res://Scenes/characters/battle_entity_enemy_default.tscn"),
	"battle_entity_enemy_elderoot" : preload("res://Scenes/characters/battle_entity_enemy_elderoot.tscn"),
	"battle_entity_enemy_core_warden" : preload("res://Scenes/characters/battle_entity_enemy_duskling.tscn"),
	"battle_entity_enemy_shadebloom" : preload("res://Scenes/characters/battle_entity_enemy_shadebloom.tscn"),
	"battle_entity_enemy_shiverling" : preload("res://Scenes/characters/battle_entity_enemy_shiverling.tscn"),
	"battle_entity_enemy_cinderling" : preload("res://Scenes/characters/battle_entity_enemy_cinderling.tscn"),
	"battle_entity_enemy_gloam" : preload("res://Scenes/characters/battle_entity_enemy_gloam.tscn"),
	}

## Used to find an entity in our glossary, with optional transform
func find_entity(glossary : String, set_prefix = null):
	var index = glossary
	if set_prefix:
		index = entity_transform(glossary,set_prefix)
	return entity[index]

## Used to transform from battle to entity or vice versa
func entity_transform(glossary_name : String, set_prefix : String):
	var result = ""
	if "world" in glossary_name:
		result = glossary_name.replace("world",set_prefix)
	elif "battle" in glossary_name:
		result = glossary_name.replace("battle",set_prefix)
	else:
		push_error("Unable to find transformation for ",glossary_name)
		
	return result
	
const particle : Dictionary = {
	"fear" : preload("res://Art/particles/scenes/particle_fear.tscn"),
	"burn" : preload("res://Art/particles/scenes/particle_burn.tscn"),
	"freeze" : preload("res://Art/particles/scenes/particle_freeze.tscn"),
	"disabled" : preload("res://Art/particles/scenes/particle_disabled.tscn")
	}

const text : Dictionary = {
	"float_away" : preload("res://Art/particles/scenes/particle_text_damage.tscn")
	}

func create_text_particle(anchor : Node, text : String = "TEST", type : String = "float_away", color : Color = Color.WHITE, delay : float = 0.0, size : int = 60):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	##Creation stuff
	var inst = Glossary.text.get(type).instantiate()
	var particle_label = inst.get_node("%particle_label")
	particle_label.text = text
	particle_label.label_settings.font_color = color
	particle_label.label_settings.font_size = size
	
	##Anchor stuff
	anchor.add_child(inst)
	#inst.global_position = anchor.global_position
	##Adjustments
	#inst.global_position.z += sign(Global.camera.global_position.z - inst.global_position.z) #Nudges us a bit toward the camera so we won't be behind the object
	
	return particle_label

const ui : Dictionary = {
	"heartstitch" : preload("res://UI/status_effect_heartstitch.tscn")
}
