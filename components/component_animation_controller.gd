extends Node
class_name component_animation_controller

@onready var direction = Vector2.ZERO

func _ready() -> void:
	
	get_parent().input_controller_direction.connect(_on_input_test_direction)
	
	#State Machine signals
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	get_parent().get_state_chart_node("/StateChart/Main/Pause_Input").state_entered.connect(_on_state_entered_pause_input)
	get_parent().get_state_chart_node("/StateChart/Main/Battle/Start").state_entered.connect(_on_state_entered_battle)

func _on_input_test_direction(dir):
	direction = dir

func animations_reset(dir : Vector2 = Vector2(0,0)):
	owner.anim_tree.get("parameters/playback").travel("Idle")

func _on_state_entered_pause_input():
	animations_reset(direction)

func _on_state_entered_battle():
	#TODO use this for selection of attack sprite.modulate = Color(1,1,1,0.5)
	#Sets us facing the right way, depending on our side
	if owner.stats.alignment == "friends":
		animations_reset(Vector2(-1,1))
	else:
		animations_reset(Vector2(1,1))

func _on_state_physics_processing_explore_idle(_delta: float):
	owner.anim_tree.get("parameters/playback").travel("Idle")

func _on_state_physics_processing_explore_walking(_delta: float):
	if direction != Vector2.ZERO:
		owner.anim_tree.set("parameters/Walking/BlendSpace2D/blend_position",direction)
		owner.anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",direction)
		owner.anim_tree.get("parameters/playback").travel("Walking")
