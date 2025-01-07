class_name component_animation_controller_battle
extends component_node

@export var my_component_input_controller : Node

var direction = Vector2.ZERO

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/Battle.state_entered.connect(_on_state_entered_battle)
	%StateChart/Main/Battle.state_exited.connect(_on_state_exited_battle)
	%StateChart/Main/Battle/Waiting.state_entered.connect(_on_state_entered_battle_waiting)
	%StateChart/Main/Battle/Execution.state_entered.connect(_on_state_entered_battle_execution)
	%StateChart/Main/Battle/Execution.state_exited.connect(_on_state_exited_battle_execution)
	%StateChart/Main/Battle/Hurt.state_entered.connect(_on_state_entered_battle_hurt)
	%StateChart/Main/Battle/Death.state_entered.connect(_on_state_entered_death)

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

func _on_state_entered_battle() -> void:
	pass

func _on_state_entered_battle_hurt() -> void:
	owner.animations.tree.get("parameters/playback").travel("Hurt")

func _on_state_entered_battle_waiting() -> void:
	owner.animations.status_hud.show()
	#Sets us facing the right way, depending on our side
	owner.animations.tree.get("parameters/playback").travel("Idle")
	if owner.alignment == Battle.alignment.FRIENDS:
		animations_reset(Vector2(1,1))
	else:
		animations_reset(Vector2(-1,-1))

func _on_state_exited_battle() -> void:
	owner.animations.status_hud.hide()

func _on_state_entered_battle_execution() -> void:
	owner.animations.status_hud.hide()
	
func _on_state_exited_battle_execution() -> void:
	owner.animations.status_hud.show()
