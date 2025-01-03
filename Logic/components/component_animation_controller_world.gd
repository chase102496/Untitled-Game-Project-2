class_name component_animation_controller_world
extends Node

@export var my_component_input_controller : Node

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_world)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_entered.connect(_on_state_entered_world_grounded_idle)
	%StateChart/Main/World/Grounded/Walking.state_entered.connect(_on_state_entered_world_grounded_walking)
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)

## Utility Functions

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

func animation_update(dir : Vector2 = Vector2(0,0)) -> void:
	
	if dir.x >= 0:
		owner.animations.rotation.y = PI
	else:
		owner.animations.rotation.y = 0
	
	owner.animations.tree.set("parameters/Walk/BlendSpace2D/blend_position",dir)
	owner.animations.tree.set("parameters/Idle/BlendSpace2D/blend_position",dir)

## Disabled

func _on_state_entered_disabled() -> void:
	owner.animations.tree.get("parameters/playback").travel("Idle")

## World

func _on_state_physics_processing_world(_delta: float) -> void:
	camera_billboard()

## Grounded

func _on_state_physics_processing_world_grounded(_delta: float) -> void:
	
	if my_component_input_controller:
		if my_component_input_controller.raw_direction != Vector2.ZERO:
			animation_update(-my_component_input_controller.raw_direction)

func _on_state_entered_world_grounded_idle() -> void:
	owner.animations.tree.get("parameters/playback").travel("Idle")

func _on_state_entered_world_grounded_walking() -> void:
	owner.animations.tree.get("parameters/playback").travel("Walk")

## Airborne
