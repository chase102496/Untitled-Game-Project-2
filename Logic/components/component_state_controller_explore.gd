class_name component_state_controller_explore
extends Node

@export var my_component_input_controller : Node
@onready var direction := Vector2.ZERO

func _ready() -> void:
	#Dialogic
	Dialogic.signal_event.connect(_on_dialogic_signal)

	#Explore
	%StateChart/Main/Explore/Walking.state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	%StateChart/Main/Explore/Idle.state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	
func _physics_process(_delta: float) -> void:
	if my_component_input_controller:
		direction = my_component_input_controller.direction

#Explore
func _on_state_physics_processing_explore_idle(_delta: float) -> void:
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")
func _on_state_physics_processing_explore_walking(_delta: float) -> void:
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

#Dialogic signals
func _on_dialogic_signal(arg : String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
