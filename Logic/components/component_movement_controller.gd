class_name component_movement_controller
extends Node

@export var my_component_input_controller : Node

var direction = Vector2.ZERO
@export var movespeed := 50
@export var max_movespeed := 3.2
@export var jump_strength = 10
@export var jump_damper_strength = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	if my_component_input_controller:
		#Direction
		direction = my_component_input_controller.direction
		
		#Jump
		if my_component_input_controller.jump:
			owner.velocity.y += jump_strength
			my_component_input_controller.jump = false
			
		#Jump damper
		if my_component_input_controller.jump_damper:
			owner.velocity.y -= move_toward(0,owner.velocity.y,jump_damper_strength)
			my_component_input_controller.jump_damper = false
	
	#Apply physics
	owner.velocity.x = move_toward(owner.velocity.x, max_movespeed * direction.x, movespeed * _delta)
	owner.velocity.z = move_toward(owner.velocity.z, max_movespeed * direction.y, movespeed * _delta)
