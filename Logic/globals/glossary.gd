extends Node

const entity : Dictionary = {
	# Players
	"player" : preload("res://scenes/characters/player.tscn"),
	# Dreamkin
	"dreamkin" : preload("res://scenes/characters/dreamkin.tscn"),
	# Enemies
	"enemy" : preload("res://scenes/characters/enemy.tscn"),
	"elderoot" : preload("res://scenes/characters/elderoot.tscn"),
	"core_warden" : preload("res://scenes/characters/core_warden.tscn"),
	"shadebloom" : preload("res://scenes/characters/shadebloom.tscn"),
	"shiverling" : preload("res://scenes/characters/shiverling.tscn"),
	"cinderling" : preload("res://scenes/characters/cinderling.tscn"),
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
	"heartstitch" : preload("res://ui/status_effect_heartstitch.tscn")
}
