extends Node

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
