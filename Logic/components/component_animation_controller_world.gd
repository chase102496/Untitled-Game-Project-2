class_name component_animation_controller_world
extends component_animation_controller

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_world)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_entered.connect(_on_state_entered_world_grounded_idle)
	%StateChart/Main/World/Grounded/Idle.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle)
	%StateChart/Main/World/Grounded/Walking.state_entered.connect(_on_state_entered_world_grounded_walking)
	%StateChart/Main/World/Grounded/Walking.state_physics_processing.connect(_on_state_physics_processing_world_grounded_walking)
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)

## Disabled

func _on_state_entered_disabled() -> void:
	
	animations.tree.set_state("Idle",true)

## World

func _on_state_physics_processing_world(_delta: float) -> void:
	camera_billboard()

## Grounded

func _on_state_physics_processing_world_grounded(_delta: float) -> void:
	
	if my_component_input_controller:
		if my_component_input_controller.raw_direction != Vector2.ZERO:
			animation_update(-my_component_input_controller.raw_direction)

func _on_state_entered_world_grounded_idle() -> void:
	animations.tree.set_state("Idle")

func _on_state_physics_processing_world_grounded_idle(_delta : float) -> void:
	pass

func _on_state_entered_world_grounded_walking() -> void:
	animations.tree.set_state("Walk")

func _on_state_physics_processing_world_grounded_walking(_delta : float) -> void:
	pass

## Airborne
