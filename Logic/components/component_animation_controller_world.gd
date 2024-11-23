class_name component_animation_controller
extends Node

@export var my_component_input_controller : Node

var direction = Vector2.ZERO

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/Explore/Idle.state_entered.connect(_on_state_entered_explore_idle)
	%StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	%StateChart/Main/Explore/Walking.state_entered.connect(_on_state_entered_explore_walking)
	%StateChart/Main/Explore/Walking.state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)

func camera_billboard() -> void:
	owner.rotation.y = Global.camera.rotation.y

func animations_reset(dir : Vector2 = Vector2(0,0)) -> void:
	if dir.x >= 0:
		owner.animations.rotation.y = PI
	else:
		owner.animations.rotation.y = 0
	owner.animations.tree.set("parameters/Idle/BlendSpace2D/blend_position",dir)
	owner.animations.tree.set("parameters/Walk/BlendSpace2D/blend_position",dir)

func _on_state_entered_death() -> void:
	pass

func _on_state_entered_battle_hurt() -> void:
	owner.animations.tree.get("parameters/playback").travel("Hurt")

func _on_state_entered_disabled() -> void:
	animations_reset(direction)
	owner.animations.tree.get("parameters/playback").travel("Idle")

func _on_state_entered_battle() -> void:
	owner.animations.status_hud.show()
	#Sets us facing the right way, depending on our side
	owner.animations.tree.get("parameters/playback").travel("Idle")
	if owner.alignment == Battle.alignment.FRIENDS:
		animations_reset(Vector2(-1,1))
	else:
		animations_reset(Vector2(1,-1))

func _on_state_exited_battle() -> void:
	owner.animations.status_hud.hide()

func _on_state_entered_battle_execution() -> void:
	owner.animations.status_hud.hide()
	
func _on_state_exited_battle_execution() -> void:
	owner.animations.status_hud.show()


func _on_state_entered_explore_idle() -> void:
	owner.animations.tree.get("parameters/playback").travel("Idle")

func _on_state_entered_explore_walking() -> void:
	owner.animations.tree.get("parameters/playback").travel("Walk")

func _on_state_physics_processing_explore(_delta: float) -> void:
	camera_billboard()

func _on_state_physics_processing_explore_walking(_delta: float) -> void:
	if my_component_input_controller:
		direction = -my_component_input_controller.raw_direction
		
	if direction != Vector2.ZERO:
		animations_reset(direction)
