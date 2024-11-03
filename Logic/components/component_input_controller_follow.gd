class_name component_input_controller_follow
extends Node

@export var my_component_movement_controller : component_movement_controller

var direction = Vector2.ZERO
var raw_direction = Vector2.ZERO
var jump : bool = false
var jump_damper : bool = false

@onready var player : CharacterBody3D = owner.get_parent().get_node("Player") #TODO this is a bit scuffed

func _ready() -> void:
	%StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/Explore.state_exited.connect(_on_state_exited_explore)

func _on_state_physics_processing_explore(_delta: float) -> void:
	#Direction
	if player:
		#Less stutter when following with snapped()
		var distance_to_player = owner.global_position.distance_to(player.global_position)
		if snapped(distance_to_player,0.1) > 1.2:
			var from = Vector2(owner.global_position.x,owner.global_position.z)
			var to = Vector2(player.global_position.x,player.global_position.z)
			var result_dir = from.direction_to(to).normalized()
			direction = Vector2(snapped(result_dir.x,0.25),snapped(result_dir.y,0.25)) #less jitter
			raw_direction = direction.rotated(Global.camera.global_rotation.y)
		else:
			direction = Vector2.ZERO
	#Jumping
	#if owner.is_on_floor() and Input.is_action_just_pressed("move_jump"): ###
	#	jump = true

func _on_state_exited_explore():
	direction = Vector2.ZERO
