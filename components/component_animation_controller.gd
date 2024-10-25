extends Node
class_name component_animation_controller

@export var my_component_input_controller : component_input_controller

var direction = Vector2.ZERO

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/Explore/Idle.state_entered.connect(_on_state_entered_explore_idle)
	%StateChart/Main/Explore/Walking.state_entered.connect(_on_state_entered_explore_walking)
	%StateChart/Main/Explore/Walking.state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	%StateChart/Main/Pause_Input.state_entered.connect(_on_state_entered_pause_input)
	%StateChart/Main/Battle.state_entered.connect(_on_state_entered_battle)
	%StateChart/Main/Battle/Death.state_entered.connect(_on_state_entered_death)

func animations_reset(dir : Vector2 = Vector2(0,0)):
	
	if dir.x >= 0:
		owner.anim_root.rotation.y = 0
	else:
		owner.anim_root.rotation.y = PI
	owner.anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",dir)
	owner.anim_tree.set("parameters/Walk/BlendSpace2D/blend_position",dir)

func _on_state_entered_death():
	pass

func _on_state_entered_pause_input():
	animations_reset(direction)
	owner.anim_tree.get("parameters/playback").travel("Idle")

func _on_state_entered_battle():
	#TODO use this for selection of attack sprite.modulate = Color(1,1,1,0.5)
	#Sets us facing the right way, depending on our side
	owner.anim_tree.get("parameters/playback").travel("Idle")
	if owner.stats.alignment == "friends":
		animations_reset(Vector2(-1,1))
	else:
		animations_reset(Vector2(1,-1))
		

func _on_state_entered_explore_idle():
	owner.anim_tree.get("parameters/playback").travel("Idle")

func _on_state_entered_explore_walking():
	owner.anim_tree.get("parameters/playback").travel("Walk")

func _on_state_physics_processing_explore_walking(_delta: float):
	
	if my_component_input_controller:
		direction = my_component_input_controller.direction
		
	if direction != Vector2.ZERO:
		animations_reset(direction)
