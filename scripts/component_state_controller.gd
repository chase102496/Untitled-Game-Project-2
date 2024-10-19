extends Node
class_name component_state_controller

@onready var direction := Vector2.ZERO
@onready var prev_direction := Vector2.ZERO

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	
	get_parent().input_controller_direction.connect(_on_input_input_controller_direction)
	
	#get_parent().get_state_chart_node("/StateChart/Main/Explore/Walking").state_input("battle").connect(_on_state_input_explore_walking)
	
	#Entered
	#$"../Pause_Input".state_entered.connect(_on_state_entered_pause_input)

func _on_input_input_controller_direction(dir):
	direction = dir

func _process(_delta: float) -> void:
	#FIXME bandaid
	if owner.state_init_override:
		owner.state_chart.send_event(owner.state_init_override)
		owner.state_init_override = null

func _on_state_physics_processing_explore_idle(_delta: float):
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")

func _on_state_physics_processing_explore_walking(_delta: float):
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

func _on_state_input_explore_walking(_delta: float):
	print("B-battle...?")

#Dialogue signals
func _on_dialogic_signal(arg:String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
