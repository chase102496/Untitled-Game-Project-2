extends Node3D

@onready var tree : AnimationTree = $character_animation_tree
@onready var player : AnimationPlayer = $character_animation_player
@onready var sprite : AnimatedSprite3D = $character_animation_sprite
@onready var selector_anchor : Marker3D = $character_animation_sprite/selector_anchor
@onready var status_hud : Node3D = $character_animation_sprite/status_hud
