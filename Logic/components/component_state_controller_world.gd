class_name component_state_controller_world
extends Node

@export var my_component_input_controller : Node
@onready var direction := Vector2.ZERO

func _ready() -> void:
	#Dialogic
	Dialogic.signal_event.connect(_on_dialogic_signal)

	#Grounded
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle)
	%StateChart/Main/World/Grounded/Walking.state_physics_processing.connect(_on_state_physics_processing_world_grounded_walking)
	
	#Airborne
	%StateChart/Main/World/Airborne.state_entered.connect(_on_state_entered_world_airborne)
	%StateChart/Main/World/Airborne.state_physics_processing.connect(_on_state_physics_processing_world_airborne)

func _physics_process(_delta: float) -> void:
	if my_component_input_controller:
		direction = my_component_input_controller.direction

## Airborne

func _on_state_entered_world_airborne() -> void:
	if owner.velocity.y >= 0:
		owner.state_chart.send_event("on_rising")
	else:
		owner.state_chart.send_event("on_falling")

func _on_state_physics_processing_world_airborne(_delta: float) -> void:
	if owner.velocity.y >= 0:
		owner.state_chart.send_event("on_rising")
	else:
		owner.state_chart.send_event("on_falling")
	
	if owner.is_on_floor():
		owner.state_chart.send_event("on_grounded")

## Grounded

func _on_state_physics_processing_world_grounded(_delta: float) -> void:
	if !owner.is_on_floor():
		owner.state_chart.send_event("on_airborne")

# Idle

func _on_state_physics_processing_world_grounded_idle(_delta: float) -> void:
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")

# Walking

func _on_state_physics_processing_world_grounded_walking(_delta: float) -> void:
	
	if my_component_input_controller:
		direction = -my_component_input_controller.raw_direction
	
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

## Dialogic signals
func _on_dialogic_signal(arg : String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
