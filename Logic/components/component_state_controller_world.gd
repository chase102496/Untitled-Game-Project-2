class_name component_state_controller_world
extends component_node

@export var my_component_input_controller : Node
@onready var direction := Vector2.ZERO

func _ready() -> void:
	#Dialogic
	Dialogic.signal_event.connect(_on_dialogic_signal)

	#Grounded
	%StateChart/Main/World/Grounded.state_entered.connect(_on_state_entered_world_grounded)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle)
	%StateChart/Main/World/Grounded/Idle/Still.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle_still)
	%StateChart/Main/World/Grounded/Idle/Sliding.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle_sliding)
	%StateChart/Main/World/Grounded/Walking.state_physics_processing.connect(_on_state_physics_processing_world_grounded_walking)
	
	#Airborne
	%StateChart/Main/World/Airborne.state_entered.connect(_on_state_entered_world_airborne)
	%StateChart/Main/World/Airborne.state_physics_processing.connect(_on_state_physics_processing_world_airborne)
	%StateChart/Main/World/Airborne/Rising.state_physics_processing.connect(_on_state_physics_processing_world_airborne_rising)
	%StateChart/Main/World/Airborne/Falling.state_physics_processing.connect(_on_state_physics_processing_world_airborne_falling)

func _physics_process(_delta: float) -> void:
	if my_component_input_controller:
		direction = my_component_input_controller.direction

## Airborne

func _on_state_entered_world_airborne() -> void:
	if owner.velocity.y >= 0:
		owner.state_chart.send_event("on_rising")
	else:
		owner.state_chart.send_event("on_falling")

func _on_state_physics_processing_world_airborne(_delta : float) -> void:
	if owner.is_on_floor():
		owner.state_chart.send_event("on_grounded")

func _on_state_physics_processing_world_airborne_rising(_delta : float) -> void:
	if owner.velocity.y < 0:
		owner.state_chart.send_event("on_falling")

func _on_state_physics_processing_world_airborne_falling(_delta : float) -> void:
	if owner.velocity.y >= 0:
		owner.state_chart.send_event("on_rising")

### Grounded

func _has_horizontal_motion() -> bool:
	if owner.velocity.x != 0 or owner.velocity.z != 0:
		return true
	else:
		return false

func _on_state_entered_world_grounded() -> void:
	if _has_horizontal_motion():
		owner.state_chart.send_event("on_walking")
	else:
		owner.state_chart.send_event("on_idle")

func _on_state_physics_processing_world_grounded(_delta : float) -> void:
	if !owner.is_on_floor():
		owner.state_chart.send_event("on_airborne")

## Idle

func _on_state_physics_processing_world_grounded_idle(_delta: float) -> void:
	if _has_horizontal_motion():
		owner.state_chart.send_event("on_walking")
	

# Still

func _on_state_physics_processing_world_grounded_idle_still(_delta : float) -> void:
	pass

# Sliding

func _on_state_physics_processing_world_grounded_idle_sliding(_delta: float) -> void:
	pass

## Walking

func _on_state_physics_processing_world_grounded_walking(_delta: float) -> void:
	
	if my_component_input_controller:
		direction = -my_component_input_controller.raw_direction
	
	if !_has_horizontal_motion():
		owner.state_chart.send_event("on_idle")

## Dialogic signals
func _on_dialogic_signal(arg : String) -> void:
	owner.state_chart.send_event(arg)
