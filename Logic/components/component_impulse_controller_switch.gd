## A user-input switch that toggles from activated to deactivated
class_name component_impulse_controller_switch
extends component_impulse_controller

## Once activated, it stays in the activated state and ignores all further signals
@export var one_way : bool = false

## The input prompt to signal to
@export var my_component_input_prompt : component_input_prompt

var current_input_prompt : Signal

enum type {
	## Like a lever. Toggles between activated and deactivated on interaction
	SWITCH,
	## Like a pressure plate. Activates when in its Area3D, and deactivates upon exiting.
	PROXIMITY,
	## Like a button. Triggers once, then goes immediately back to deactivated after a short cooldown
	BUTTON
}

##Determines how this switch operates
@export var type_selection : type = type.SWITCH

func _ready() -> void:
	
	#Import our parent ready func
	super._ready()
	
	my_component_interact_reciever.set_collision_mask_value(5,true)
	my_component_interact_reciever.set_collision_layer_value(5,true)
	
	## States
	$StateChart/Main/Deactivated.state_entered.connect(on_state_entered_deactivated)
	$StateChart/Main/Deactivated.state_exited.connect(on_state_exited_deactivated)
	$StateChart/Main/Activated.state_entered.connect(on_state_entered_activated)
	$StateChart/Main/Activated.state_exited.connect(on_state_exited_activated)
	
	## Signals
	match type_selection:
		type.SWITCH:
			my_component_interact_reciever.enter.connect(_on_area_enter_switch)
			my_component_interact_reciever.exit.connect(_on_area_exit_switch)
			my_component_interact_reciever.interact.connect(_on_area_interact_switch)
		type.BUTTON:
			my_component_interact_reciever.enter.connect(_on_area_enter_button)
			my_component_interact_reciever.exit.connect(_on_area_exit_button)
			my_component_interact_reciever.interact.connect(_on_area_interact_button)
		type.PROXIMITY:
			pass

func _interact_timer_timeout() -> void:
	super._interact_timer_timeout()
	_update_input_prompt()

## Checks a bunch of stuff to see what groups we're in so we can prompt the right button
func _update_input_prompt(signal_name : Signal = current_input_prompt) -> void:
	## Making sure we don't prompt for proximity, as it doesn't require input
	if my_component_interact_reciever and type_selection != type.PROXIMITY:
		if _is_interact_timer_running():
			current_input_prompt = signal_name
		else:
			var groups : Array = my_component_interact_reciever.get_groups()
			var input_name : String
			
			## Interact prompt display, interpreted from the groups I am in
			if "interact_general" in groups:
				input_name = "interact"
				signal_name.emit(input_name)
			## Ability button
			elif Global.array_contains_starts_with(groups,"interact_ability"):
				input_name = "interact_secondary"
				signal_name.emit(input_name)

### --- States --- ###

func on_state_entered_deactivated() -> void:
	deactivated.emit()

func on_state_exited_deactivated() -> void:
	pass

func on_state_entered_activated() -> void:
	activated.emit()

func on_state_exited_activated() -> void:
	pass

### --- Switch --- ###

func _on_transition_switch(source : Node) -> void:
	
	## Cooldown'd by interact_timer
	if !_is_interact_timer_running():
		## No player inside zone, no need to update areas
		if my_component_interact_reciever.get_overlapping_areas().is_empty():
			state_chart.send_event("on_transition")
		## Simulate leaving the current area and entering the new one
		else:
			_on_area_exit_switch(source)
			state_chart.send_event("on_transition")
			_on_area_enter_switch(source)
		
		_start_interact_timer()

func _on_area_enter_switch(source : Node) -> void:
	Debug.message(["_on_area_enter_switch ",debug_name])
	_update_input_prompt(my_component_input_prompt.input_open)

func _on_area_interact_switch(source : Node) -> void:
	Debug.message(["_on_area_interact_switch ",debug_name])
	_on_transition_switch(source)

func _on_area_exit_switch(source : Node) -> void:
	Debug.message(["_on_area_exit_switch ",debug_name])
	_update_input_prompt(my_component_input_prompt.input_closed)

### --- Button --- ###

func _on_transition_button(source : Node) -> void:
	
	if my_component_interact_reciever.get_overlapping_areas().is_empty():
		state_chart.send_event("on_transition")
	## Simulate leaving the current area and entering the new one
	else:
		_on_area_exit_button(source)
		state_chart.send_event("on_transition")
		_on_area_enter_button(source)

func _on_area_enter_button(source : Node) -> void:
	Debug.message(["_on_area_enter_button ",debug_name])
	
	if state_chart.get_current_state() == "Deactivated":
		_update_input_prompt(my_component_input_prompt.input_open)

func _on_area_interact_button(source : Node) -> void:
	Debug.message(["_on_area_interact_button ",debug_name])
	
	if state_chart.get_current_state() == "Deactivated":
		_update_input_prompt(my_component_input_prompt.input_closed)
		_start_interact_timer()
		_on_transition_button(source)
		await interact_timer.timeout
		_on_transition_button(source)

func _on_area_exit_button(source : Node) -> void:
	Debug.message(["_on_area_exit_button ",debug_name])
	_update_input_prompt(my_component_input_prompt.input_closed)
