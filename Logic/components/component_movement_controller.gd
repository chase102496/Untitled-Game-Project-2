class_name component_movement_controller
extends component_node

@export var my_component_input_controller : Node
@export var my_component_physics : component_physics

var movement_direction : Vector2 = Vector2.ZERO
@export var deceleration : float = 25
@export var movespeed : float = 50
@export var max_movespeed : float = 5
@export var jump_strength : float = 9
## This is what amount of our jump strength's force is applied when we let go
@export var jump_damper_coeff : float = 0.8
## This will be how much gravity we have while holding jump
@export var jump_grav_coeff : float = 0.7

func _ready() -> void:
	if my_component_input_controller:
		my_component_input_controller.jump.connect(_on_jump)
		my_component_input_controller.jump_damper.connect(_on_jump_damper)
		my_component_input_controller.jump_grav.connect(_on_jump_grav)
		my_component_input_controller.grav_reset.connect(_on_grav_reset)
		my_component_input_controller.velocity_reset.connect(_on_velocity_reset)

## The RULE of this component, is it does NOT do any LOGIC or if statements regarding the context, it ONLY APPLIES PHYSICS.
## So for example, we would define the conditions of the control signal jump to run in input, signal it, 
## and play them out here calculation-wise

## Signals

func _on_jump() -> void:
	owner.velocity.y += jump_strength

func _on_jump_damper() -> void:
	_on_grav_reset()
	if my_component_input_controller:
		owner.velocity.y -= owner.velocity.y*jump_damper_coeff

func _on_jump_grav() -> void:
	if my_component_physics:
		my_component_physics.grav = jump_grav_coeff*my_component_physics.base_grav

func _on_grav_reset() -> void:
	if my_component_physics:
		my_component_physics.grav_reset()

func _on_velocity_reset() -> void:
	owner.velocity = Vector3.ZERO

## Etc

func _physics_process(_delta: float) -> void:
	
	if my_component_input_controller and my_component_input_controller.direction.length() != 0:
		movement_direction = my_component_input_controller.direction
		owner.velocity.x = move_toward(owner.velocity.x, max_movespeed * movement_direction.x, movespeed * _delta)
		owner.velocity.z = move_toward(owner.velocity.z, max_movespeed * movement_direction.y, movespeed * _delta)
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, deceleration * _delta)
		owner.velocity.z = move_toward(owner.velocity.z, 0, deceleration * _delta)
