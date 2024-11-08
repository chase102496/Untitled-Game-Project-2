extends Node

const entity : Dictionary = {
	"player" : preload("res://scenes/characters/player.tscn"),
	"enemy" : preload("res://scenes/characters/enemy.tscn"),
	"dreamkin" : preload("res://scenes/characters/dreamkin.tscn")
	}

const particle : Dictionary = {
	"fear" : preload("res://Art/particles/scenes/particle_fear.tscn"),
	"burn" : preload("res://Art/particles/scenes/particle_burn.tscn")
	}

const ui : Dictionary = {
	"heartstitch" : preload("res://ui/status_effect_heartstitch.tscn")
}
