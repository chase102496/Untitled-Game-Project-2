extends Node
class_name component_input_controller

func _physics_process(_delta: float) -> void:
	#Direction
	var direction = Vector2.ZERO
	direction = Input.get_vector("move_right","move_left","move_forward","move_backward")
	get_parent().input_controller_direction.emit(direction)
	#Jumping
	if owner.is_on_floor() and Input.is_action_just_pressed("move_jump"):
		get_parent().input_controller.emit("move_jump")
	#Jump damping
	if !Input.is_action_pressed("move_jump") and !owner.is_on_floor() and owner.velocity.y > 0:
		get_parent().input_controller.emit("move_jump_damper")
	
	#FIXME
	# MAKE SURE YOU UNDERSTAND THE ORDER OF THE OBJECT IS THE ORDER THEY WILL TAKE TURNS IN
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize([owner,owner,owner,owner],[{"test":123},{"ababab":60000000},{"alignment":"foes"},{"alignment":"foes"}],get_tree(),"res://scenes/turn_arena3d.tscn")
