extends Node
class_name component_animation_controller

var direction := Vector2.ZERO
var prev_direction := Vector2.ZERO

func _ready() -> void:
	
	get_parent().input_controller.connect(_on_input_controller_event)
	
	#State Machine signals
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	get_parent().get_state_chart_node("/StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	get_parent().get_state_chart_node("/StateChart/Main/Pause_Input").state_entered.connect(_on_state_entered_pause_input)

func animations_reset(dir : Vector2 = Vector2(0,0)):
	owner.anim_tree.get("parameters/playback").travel("Idle")
	owner.anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",dir)

func _on_input_controller_event(input_name, param1 = null):
	if input_name == "direction" :
		direction = param1
		if direction != Vector2.ZERO:
			prev_direction = direction

func _on_state_entered_pause_input():
	animations_reset(direction)

func _on_state_physics_processing_explore_idle(_delta: float):
	owner.anim_tree.get("parameters/playback").travel("Idle")

func _on_state_physics_processing_explore_walking(_delta: float):
	if direction != Vector2.ZERO:
		owner.anim_tree.set("parameters/Walking/BlendSpace2D/blend_position",direction)
		owner.anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",direction)
		owner.anim_tree.get("parameters/playback").travel("Walking")
