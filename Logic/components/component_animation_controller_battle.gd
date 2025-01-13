class_name component_animation_controller_battle
extends component_animation_controller

func _ready() -> void:
	#State Machine signals
	%StateChart/Main/Battle.state_entered.connect(_on_state_entered_battle)
	%StateChart/Main/Battle.state_exited.connect(_on_state_exited_battle)
	%StateChart/Main/Battle/Waiting.state_entered.connect(_on_state_entered_battle_waiting)
	%StateChart/Main/Battle/Execution.state_entered.connect(_on_state_entered_battle_execution)
	%StateChart/Main/Battle/Execution.state_exited.connect(_on_state_exited_battle_execution)
	%StateChart/Main/Battle/Hurt.state_entered.connect(_on_state_entered_battle_hurt)
	%StateChart/Main/Battle/Dying.state_entered.connect(_on_state_entered_battle_dying)
	%StateChart/Main/Battle/Death.state_entered.connect(_on_state_entered_death)

func _on_state_entered_battle_dying() -> void:
	animations.tree.set_state("Death")

func _on_state_entered_death() -> void:
	pass

func _on_state_entered_battle() -> void:
	pass

func _on_state_entered_battle_hurt() -> void:
	animations.tree.set_state("Hurt")

func _on_state_entered_battle_waiting() -> void:
	#Sets us facing the right way, depending on our side
	animations.tree.set_state("Idle")
	
	if owner.alignment == Battle.alignment.FRIENDS:
		animation_update(Vector2(1,1))
	else:
		animation_update(Vector2(-1,-1))

func _on_state_exited_battle() -> void:
	pass

func _on_state_entered_battle_execution() -> void:
	pass
	
func _on_state_exited_battle_execution() -> void:
	pass
