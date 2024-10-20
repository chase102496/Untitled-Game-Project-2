extends Node
class_name component_state_controller

@onready var direction := Vector2.ZERO
@onready var prev_direction := Vector2.ZERO

func _ready() -> void:
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	owner.get_node("StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	owner.get_node("StateChart/Main/Explore").state_physics_processing.connect(_on_state_physics_processing_explore)
	owner.get_node("StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	get_parent().input_controller_direction.connect(_on_input_input_controller_direction)
	
func _on_input_input_controller_direction(dir):
	direction = dir

func _process(_delta: float) -> void:
	
	#FIXME bandaid
	if owner.state_init_override:
		owner.state_chart.send_event(owner.state_init_override)
		owner.state_init_override = null

func _on_state_physics_processing_explore(_delta: float):
		
	if Input.is_action_just_pressed("interact"):
		Dialogic.start("timeline")
	
	# MAKE SURE YOU UNDERSTAND THE ORDER OF THE OBJECT IS THE ORDER THEY WILL TAKE TURNS IN LATER
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize([owner,owner,owner,owner],[{"test":123},{"ababab":60000000},{"alignment":"foes"},{"alignment":"foes"}],owner.get_tree(),"res://scenes/turn_arena.tscn")

func _on_state_physics_processing_explore_idle(_delta: float):
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")

func _on_state_physics_processing_explore_walking(_delta: float):
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

#Dialogue signals
func _on_dialogic_signal(arg : String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
