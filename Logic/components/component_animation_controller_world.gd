class_name component_animation_controller_world
extends component_animation_controller

func _ready() -> void:
	
	#Jump detection
	my_component_input_controller.jump.connect(_on_jump)
	
	#State Machine signals
	%StateChart/Main/World.state_physics_processing.connect(_on_state_physics_processing_world)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Grounded.state_entered.connect(_on_state_entered_world_grounded)
	%StateChart/Main/World/Grounded/Idle.state_entered.connect(_on_state_entered_world_grounded_idle)
	%StateChart/Main/World/Grounded/Idle.state_physics_processing.connect(_on_state_physics_processing_world_grounded_idle)
	%StateChart/Main/World/Grounded/Walking.state_entered.connect(_on_state_entered_world_grounded_walking)
	%StateChart/Main/World/Grounded/Walking.state_physics_processing.connect(_on_state_physics_processing_world_grounded_walking)
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	%StateChart/Main/World/Airborne.state_entered.connect(_on_state_entered_world_airborne)
	%StateChart/Main/World/Airborne.state_physics_processing.connect(_on_state_physics_processing_world_airborne)

## Jump

func _on_jump() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(owner.animations.transformer,"scale",Vector3(0.8,1.2,1),0.1)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(owner.animations.transformer,"scale",Vector3(1,1,1),0.2)

## Disabled

func _on_state_entered_disabled() -> void:
	animations.tree.set_state("Idle",true)

## World

func _on_state_physics_processing_world(_delta: float) -> void:
	camera_billboard()

## Grounded

## Falling scaling based on velocity
func _on_state_entered_world_grounded() -> void:
	
	var vel_list : Array = []
	
	for vel in owner.my_component_physics.get_velocity_history(5):
		vel_list.append(vel.y)
	
	var vel_min : float = vel_list.min()
	
	var scale_factor = lerp(1.05, 1.8, clamp(-vel_min / 80, 0.0, 1.0))
	var scale_x = scale_factor
	var scale_y = max(2 - scale_x,0.2)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(owner.animations.transformer,"scale",Vector3(scale_x,scale_y,1),0.04)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(owner.animations.transformer,"scale",Vector3(1,1,1),0.15)
	
	Glossary.create_fx_particle_custom(owner.animations.selector_feet,"dust",true,-1,180,1,Vector3(0,0,0),Global.palette["Oxford Blue"])

func _on_state_physics_processing_world_grounded(_delta: float) -> void:
	animation_update()

func _on_state_entered_world_grounded_idle() -> void:
	animations.tree.set_state("Idle")

func _on_state_physics_processing_world_grounded_idle(_delta : float) -> void:
	pass

func _on_state_entered_world_grounded_walking() -> void:
	animations.tree.set_state("Walk")

func _on_state_physics_processing_world_grounded_walking(_delta : float) -> void:
	pass

## Airborne

func _on_state_entered_world_airborne() -> void:
	animations.tree.set_state("Air")

func _on_state_physics_processing_world_airborne(_delta : float) -> void:
	animation_update(Vector3(0,owner.velocity.y,0))
