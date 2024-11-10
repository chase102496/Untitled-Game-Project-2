extends Node

const entity : Dictionary = {
	"player" : preload("res://scenes/characters/player.tscn"),
	"enemy" : preload("res://scenes/characters/enemy.tscn"),
	"enemy_briarback" : preload("res://scenes/characters/enemy_briarback.tscn"),
	"dreamkin" : preload("res://scenes/characters/dreamkin.tscn")
	}

const particle : Dictionary = {
	"fear" : preload("res://Art/particles/scenes/particle_fear.tscn"),
	"burn" : preload("res://Art/particles/scenes/particle_burn.tscn"),
	"freeze" : preload("res://Art/particles/scenes/particle_freeze.tscn"),
	}

const text : Dictionary = {
	"float_away" : preload("res://Art/particles/scenes/particle_text_damage.tscn")
	}

func create_text_particle(host : Node, pos : Vector3 = Vector3.ZERO, text : String = "TEST", type : String = "float_away", color : Color = Color.WHITE, size : int = 60):
	var inst = Glossary.text.get(type).instantiate()
	host.add_child(inst)
	var particle_label = inst.get_node("%particle_label")
	particle_label.text = text
	particle_label.label_settings.font_color = color
	particle_label.label_settings.font_size = size
	inst.global_position = pos

const ui : Dictionary = {
	"heartstitch" : preload("res://ui/status_effect_heartstitch.tscn")
}
