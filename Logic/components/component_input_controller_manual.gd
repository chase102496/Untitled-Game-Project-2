class_name component_input_controller_manual
extends Node

var direction = Vector2.ZERO
var raw_direction = Vector2.ZERO
var jump : bool = false
var jump_damper : bool = false

func _ready() -> void:
	%StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/Explore.state_exited.connect(_on_state_exited_explore)

func _on_state_physics_processing_explore(_delta: float) -> void:
	#Direction
	raw_direction = Input.get_vector("move_left","move_right","move_forward","move_backward")
	direction = raw_direction.rotated(-Global.camera.global_rotation.y)
	#Jumping
	if owner.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		#TODO
		jump_damper = false
		jump = true
	#Jump damping
	if !Input.is_action_pressed("move_jump") and !owner.is_on_floor() and owner.velocity.y > 0:
		#TODO
		jump_damper = true
		jump = false
	
	if Input.is_action_just_pressed("ui_cancel"):
		owner.my_inventory_gui.state_chart.send_event("on_gui_toggle")

func _on_state_exited_explore():
	direction = Vector2.ZERO
