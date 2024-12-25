extends Node3D

@export var tree : AnimationTree
@export var player : AnimationPlayer
@export var sprite : AnimatedSprite3D
@export var selector_anchor : Marker3D
@export var status_hud : Node3D

func import_visual_set(dict : Dictionary) -> void:
	for key in dict:
		match key:
			"SpriteFrames":
				sprite.sprite_frames = dict[key]
			"AnimationLibrary":
				player.libraries[""] = dict[key]
			"AnimationNodeStateMachine":
				tree.tree_root = dict[key]
