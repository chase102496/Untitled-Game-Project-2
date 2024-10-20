extends Node
class_name component_input_controller

var direction = Vector2.ZERO

func _ready() -> void:
	owner.get_node("StateChart/Main/Explore").state_physics_processing.connect(_on_state_physics_processing_explore)
	owner.get_node("StateChart/Main/Explore").state_exited.connect(_on_state_exited_explore)

func reset_inputs():
	direction = Vector2.ZERO
	get_parent().input_controller_direction.emit(direction)

func _on_state_physics_processing_explore(_delta: float) -> void:
	#Direction
	direction = Input.get_vector("move_right","move_left","move_backward","move_forward")
	get_parent().input_controller_direction.emit(direction)
	#Jumping
	if owner.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		get_parent().input_controller.emit("move_jump")
	#Jump dampingd
	if !Input.is_action_pressed("move_jump") and !owner.is_on_floor() and owner.velocity.y > 0:
		get_parent().input_controller.emit("move_jump_damper")

func _on_state_exited_explore():
	reset_inputs()
