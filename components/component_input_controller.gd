extends Node
class_name component_input_controller

var direction = Vector2.ZERO
var jump : bool = false
var jump_damper : bool = false

func _ready() -> void:
	%StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/Explore.state_exited.connect(_on_state_exited_explore)

func _on_state_physics_processing_explore(_delta: float) -> void:
	#Direction
	direction = Input.get_vector("move_right","move_left","move_backward","move_forward")
	#Jumping
	if owner.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		#TODO
		jump_damper = false
		jump = true
	#Jump dampingd
	if !Input.is_action_pressed("move_jump") and !owner.is_on_floor() and owner.velocity.y > 0:
		#TODO
		jump_damper = true
		jump = false

func _on_state_exited_explore():
	direction = Vector2.ZERO
