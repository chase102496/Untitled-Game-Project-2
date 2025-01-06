class_name component_physics
extends Node

#For functions, emit a signal, and then just connect it on the parent end and create a function to run when it is signalled

#Use "owner" to call our owner

var grav : float # Realtime gravity adding
var _enabled : bool = true
var velocity_history : Array = []

@export var base_grav : float = 35 # To revert to our default
@export var max_grav : float = -70 # Our max downward velocity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grav_reset()

func enable():
	owner.set_collision_layer_value(1,true)
	_enabled = true

func disable():
	owner.set_collision_layer_value(1,false)
	_enabled = false

func grav_reset() -> void:
	grav = base_grav

func _clean_velocity_history() -> void:
	## Limit to 60 units
	if velocity_history.size() > 60:
		velocity_history.pop_front()
		_clean_velocity_history()

func _store_velocity_history() -> void:
	velocity_history.append(owner.velocity)
	_clean_velocity_history()

func get_velocity_history(depth : int = 60) -> Array:
	if depth > 60:
		push_error("Velocity History is not stored for more than 60 previous frames : ",depth)
		return velocity_history
	else:
		return velocity_history.slice(velocity_history.size() - depth)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _enabled:
		_store_velocity_history()
		owner.move_and_slide()
		owner.velocity.y = move_toward(owner.velocity.y, max_grav, grav * delta)
