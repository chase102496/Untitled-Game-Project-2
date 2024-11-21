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

var entity_class : Dictionary = {
	"world_entity_dreamkin_default" : world_entity_dreamkin_default,
	"battle_entity_dreamkin_default" : battle_entity_dreamkin_default,
	#"battle_entity_dreamkin_sparx" : world_entity_dreamkin_sparx,
}

#GOING TO BE DEPRECATED SOON, USE BATTLE_
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

func find_entity_class(glossary : String, transform : bool = false):
	var index = glossary
	if transform:
		index = entity_transform(glossary)
	return entity_class[index]

func entity_transform(glossary_name : String):
	var result = ""
	if "world" in glossary_name:
		result = glossary_name.replace("world","battle")
	elif "battle" in glossary_name:
		result = glossary_name.replace("battle","world")
	else:
		push_error("Unable to find transformation for ",glossary_name)
		
	return result

func create_entity_world(entity_name : String):
	return entity["world_"+entity_name].instantiate()

const particle : Dictionary = {
	"fear" : preload("res://Art/particles/scenes/particle_fear.tscn"),
	"burn" : preload("res://Art/particles/scenes/particle_burn.tscn"),
	"freeze" : preload("res://Art/particles/scenes/particle_freeze.tscn"),
	"disabled" : preload("res://Art/particles/scenes/particle_disabled.tscn")
	}

const text : Dictionary = {
	"float_away" : preload("res://Art/particles/scenes/particle_text_damage.tscn")
	}

func create_text_particle(host : Node, pos : Vector3 = Vector3.ZERO, text : String = "TEST", type : String = "float_away", color : Color = Color.WHITE, delay : float = 0.0, size : int = 60):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	var inst = Glossary.text.get(type).instantiate()
	host.add_child(inst)
	var particle_label = inst.get_node("%particle_label")
	particle_label.text = text
	particle_label.label_settings.font_color = color
	particle_label.label_settings.font_size = size
	
	inst.global_position = pos
	return particle_label

const ui : Dictionary = {
	"heartstitch" : preload("res://UI/status_effect_heartstitch.tscn")
}
