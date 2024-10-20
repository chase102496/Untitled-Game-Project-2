class_name component_movement_controller
extends Node

#For functions, emit a signal, and then just connect it on the parent end and create a function to run when it is signalled
#Use "owner" to call our owner

@onready var direction = Vector2.ZERO

var movespeed := 50
var max_movespeed := 3.2
var jump := 10
var jump_damper := 1
var jump_start := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().input_controller.connect(_on_input_controller_event)
	get_parent().input_controller_direction.connect(_on_input_controller_direction)

func _on_input_controller_direction(dir):
	direction = dir

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	owner.velocity.x = move_toward(owner.velocity.x, max_movespeed * direction.x, movespeed * delta)
	owner.velocity.z = move_toward(owner.velocity.z, max_movespeed * direction.y, movespeed * delta)

func _on_input_controller_event(input_name, param1 = null):
	#Jump
	if input_name == "move_jump":
		owner.velocity.y += jump
		
	#Jump damper
	if input_name == "move_jump_damper":
		owner.velocity.y -= move_toward(0,owner.velocity.y,jump_damper)
