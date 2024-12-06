class_name component_input_controller_default
extends Node

@export var my_component_movement_controller : component_movement_controller

var direction : Vector2 = Vector2.ZERO
var raw_direction : Vector2 = Vector2.ZERO
var jumping : bool = false

signal jump
signal jump_damper
signal jump_grav
signal grav_reset
signal velocity_reset
