class_name component_animation_controller_world
extends component_node

@export var my_component_input_controller : Node
@export var animations : component_animation

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_world)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_entered.connect(_on_state_entered_world_grounded_idle)
	%StateChart/Main/World/Grounded/Idle.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle)
	%StateChart/Main/World/Grounded/Walking.state_entered.connect(_on_state_entered_world_grounded_walking)
	%StateChart/Main/World/Grounded/Walking.state_physics_processing.connect(_on_state_physics_processing_world_grounded_walking)
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)

## Utility Functions

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

func animation_update(dir : Vector2 = Vector2(0,0)) -> void:
	
	if dir.x > 0:
		animations.rotation.y = PI
	elif dir.x < 0:
		animations.rotation.y = 0
	else:
		pass #Keep current direction if we didn't change it
	
	animations.tree.set_blend_2d(dir,"Idle")
	animations.tree.set_blend_2d(dir,"Walk")

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
