class_name component_physics
extends Node

#For functions, emit a signal, and then just connect it on the parent end and create a function to run when it is signalled

#Use "owner" to call our owner

var grav : float = 40
var max_grav : float = -70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	owner.move_and_slide()
	owner.velocity.y = move_toward(owner.velocity.y, max_grav, grav * delta)
