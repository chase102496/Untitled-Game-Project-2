class_name component_input_controller_manual
extends component_input_controller_default

@export var my_component_interaction : component_interaction
@export var my_component_world_ability : component_world_ability

var jump_damper_cooldown : bool = false
var jump_queued : bool = false
var coyote_time_queued : bool

func _ready() -> void:
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	%StateChart/Main/World.state_input.connect(_on_state_input_world)
	%StateChart/Main/World/Grounded.state_entered.connect(_on_state_entered_world_grounded)
	%StateChart/Main/World/Grounded.state_physics_processing.connect(_on_state_physics_processing_world_grounded)
	%StateChart/Main/World/Airborne.state_physics_processing.connect(_on_state_physics_processing_world_airborne)
	%StateChart/Main/World/Airborne/Rising.state_entered.connect(_on_state_entered_world_airborne_rising)
	%StateChart/Main/World/Airborne/Rising.state_exited.connect(_on_state_exited_world_airborne_rising)
	%StateChart/Main/World/Airborne/Rising.state_physics_processing.connect(_on_state_physics_processing_world_airborne_rising)
	%StateChart/Main/World/Airborne/Falling.state_entered.connect(_on_state_entered_world_airborne_falling)
	%StateChart/Main/World/Airborne/Falling.state_physics_processing.connect(_on_state_physics_processing_world_airborne_falling)

## Utility Functions

func reset_direction() -> void:
	raw_direction = Vector2.ZERO
	direction = Vector2.ZERO

func update_direction() -> void:
	raw_direction = Input.get_vector("move_left","move_right","move_forward","move_backward")
	direction = raw_direction.rotated(-Global.camera.global_rotation.y) #Move relative to camera

## Disabled

func _on_state_entered_disabled() -> void:
	reset_direction()
	
## World

func _on_state_input_world(event : InputEvent) -> void:
	
	## E
	if Input.is_action_just_pressed("interact"):
		my_component_interaction.interact()
	
	## Q
	if Input.is_action_just_pressed("interact_secondary"):
		my_component_world_ability.toggle_active()
	
	## R
	if Input.is_action_just_pressed("equipment_use"):
		my_component_world_ability.ability_use()
	
	## Esc
	if Input.is_action_just_pressed("ui_cancel"):
		my_component_world_ability.ability_event(my_component_world_ability.active,"on_cancel")

## TODO ADD EQUIPMENT INTERACTION AND STUFF HERE

# Grounded

func _on_state_entered_world_grounded() -> void:
	grav_reset.emit()
	coyote_time_queued = true

func _on_state_physics_processing_world_grounded(_delta: float) -> void:
	update_direction()
	
	#Jumping
	if Input.is_action_just_pressed("move_jump") or jump_queued:
		jump.emit()
		jump_grav.emit()
		jump_queued = false
		coyote_time_queued = false
	
	if Input.is_action_just_pressed("inventory"):
		owner.state_chart.send_event("on_disabled")
		owner.my_world_gui.state_chart.send_event("on_gui_enabled")

# Airborne

func _on_state_physics_processing_world_airborne(_delta: float) -> void:
	update_direction()
	
	if Input.is_action_just_pressed("move_jump"):
		jump_queued = true
		await get_tree().create_timer(0.2).timeout
		jump_queued = false

func _on_state_entered_world_airborne_rising() -> void:
	jump_damper_cooldown = true

func _on_state_physics_processing_world_airborne_rising(_delta: float) -> void:
	if !Input.is_action_pressed("move_jump") and jump_damper_cooldown:
		jump_damper.emit()
		jump_damper_cooldown = false
	
	coyote_time_queued = false #Set here because we have default state set to rising and it triggers the entered state

func _on_state_exited_world_airborne_rising() -> void:
	pass

func _on_state_entered_world_airborne_falling() -> void:
	grav_reset.emit()

func _on_state_physics_processing_world_airborne_falling(_delta: float) -> void:

	if coyote_time_queued:
		if Input.is_action_just_pressed("move_jump"):
			velocity_reset.emit() #This is so we don't get a baby jump
			jump.emit()
			jump_grav.emit()
			coyote_time_queued = false
			
		await get_tree().create_timer(0.1).timeout
		coyote_time_queued = false
