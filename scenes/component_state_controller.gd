extends Node
class_name component_state_controller

var direction := Vector2.ZERO

func _ready() -> void:
	#Connecting to dialogue signals
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	#Connecting to input controller
	get_parent().input_controller.connect(_on_input_controller_event)
	
	#	State Machine Signals
	#Battle
	#$"../Battle".state_entered.connect(_on_state_entered_battle)
	#$"../Battle".state_physics_processing.connect(_on_state_physics_processing_battle)
	#Physics
	
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	
	#Entered
	#$"../Pause_Input".state_entered.connect(_on_state_entered_pause_input)
	

func _process(_delta: float) -> void:
	#FIXME bandaid
	if owner.state_init_override:
		owner.state_chart.send_event(owner.state_init_override)
		owner.state_init_override = null

func _on_input_controller_event(input_name, param1 = null):
	if input_name == "direction" :
		direction = param1

func _on_state_physics_processing_explore_idle(_delta: float):
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")

func _on_state_physics_processing_explore_walking(_delta: float):
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

#Dialogue signals
func _on_dialogic_signal(arg:String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
