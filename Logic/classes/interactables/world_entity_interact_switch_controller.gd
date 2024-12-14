class_name world_entity_interact_switch_controller
extends world_entity_interact

signal activated
signal deactivated

## Once activated, it stays in the activated state and ignores all further signals
@export var one_way : bool = false

func _ready() -> void:
	
	#Initial state
	update_signals("deactivated", true)
	update_collision(true)
	
	$StateChart/Main/Deactivated.state_entered.connect(on_state_entered_deactivated)
	$StateChart/Main/Deactivated.state_exited.connect(on_state_exited_deactivated)
	$StateChart/Main/Activated.state_entered.connect(on_state_entered_activated)
	$StateChart/Main/Activated.state_exited.connect(on_state_exited_activated)

## --- Deactivated --- ###

func on_state_entered_deactivated() -> void:
	deactivated.emit()

#

func _on_target_entered_deactivated(source : Node) -> void:
	#print_debug("_on_target_entered_deactivated")
	pass

func _on_target_exited_deactivated(source : Node) -> void:
	#print_debug("_on_target_exited_deactivated")
	pass

func _on_target_interact_deactivated(source : Node) -> void:
	#print_debug("_on_target_interact_deactivated")
	my_state_transition("deactivated","activated")

#

func on_state_exited_deactivated() -> void:
	pass

## --- Activated --- ##

func on_state_entered_activated() -> void:
	activated.emit()
	if one_way:
		update_signals("activated", false)
		update_collision(false)

#

func _on_target_entered_activated(source : Node) -> void:
	#print_debug("_on_target_entered_activated")
	pass

func _on_target_exited_activated(source : Node) -> void:
	#print_debug("_on_target_exited_activated")
	pass

func _on_target_interact_activated(source : Node) -> void:
	#print_debug("_on_target_interact_activated")
	my_state_transition("activated","deactivated")

#

func on_state_exited_activated() -> void:
	pass
