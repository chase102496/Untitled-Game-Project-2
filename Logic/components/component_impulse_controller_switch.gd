class_name component_impulse_controller_switch
extends component_impulse_controller

## Once activated, it stays in the activated state and ignores all further signals
@export var one_way : bool = false

enum type {
	## Like a lever. Toggles between activated and deactivated on interaction
	SWITCH,
	## Like a pressure plate. Activates when in its Area3D, and deactivates upon exiting.
	PROXIMITY
}
##Determines how this switch operates
@export var type_selection : type = type.SWITCH

func _ready() -> void:
	
	#Import our parent ready func
	super._ready()
	
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
	print_debug("_on_target_entered_deactivated ",debug_name)
	
	if type_selection == type.PROXIMITY:
		my_state_transition("deactivated","activated",true)

func _on_target_exited_deactivated(source : Node) -> void:
	print_debug("_on_target_exited_deactivated ",debug_name)
	pass

func _on_target_interact_deactivated(source : Node) -> void:
	print_debug("_on_target_interact_deactivated ",debug_name)
	
	if type_selection == type.SWITCH:
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
	print_debug("_on_target_entered_activated ",debug_name)
	pass

func _on_target_exited_activated(source : Node) -> void:
	print_debug("_on_target_exited_activated ",debug_name)
	
	if type_selection == type.PROXIMITY:
		my_state_transition("activated","deactivated",true)

func _on_target_interact_activated(source : Node) -> void:
	print_debug("_on_target_interact_activated ",debug_name)
	
	if type_selection == type.SWITCH:
		my_state_transition("activated","deactivated")

#

func on_state_exited_activated() -> void:
	pass
