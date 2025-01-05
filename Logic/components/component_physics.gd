class_name component_physics
extends Node

#For functions, emit a signal, and then just connect it on the parent end and create a function to run when it is signalled

#Use "owner" to call our owner

var grav : float # Realtime gravity adding
var _enabled : bool = true

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if _enabled:
		owner.move_and_slide()
		owner.velocity.y = move_toward(owner.velocity.y, max_grav, grav * delta)
	else:
		pass
