## A user-input switch that toggles from activated to deactivated
class_name component_impulse_controller_switch
extends component_impulse_controller

## Once activated, it stays in the activated state and ignores all further signals no matter what
@export var is_one_way : bool = false

## The input prompt to signal to
@export var my_component_input_prompt : component_input_prompt

## Keeps track of input prompt when it isn't displayed to update it later
var current_input_prompt : Signal

## The way interaction is handled
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
	$StateChart/Main/Deactivated.state_entered.connect(_on_state_entered_deactivated)
	$StateChart/Main/Deactivated.state_exited.connect(_on_state_exited_deactivated)
	$StateChart/Main/Activated.state_entered.connect(_on_state_entered_activated)
	$StateChart/Main/Activated.state_exited.connect(_on_state_exited_activated)
	$StateChart/Main/PreDisabled.state_entered.connect(_on_state_entered_predisabled)
	$StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	
	my_component_interact_reciever.enter.connect(_on_area_enter)
	my_component_interact_reciever.interact.connect(_on_area_interact)
	my_component_interact_reciever.exit.connect(_on_area_exit)
	

## Checks a bunch of stuff to see what groups we're in so we can prompt the right button
func _update_input_prompt(signal_name : Signal = current_input_prompt, respect_interact_timer : bool = true) -> void:
	
	## Making sure we don't prompt for proximity, as it doesn't require input
	if my_component_interact_reciever:
		if _is_interact_timer_running() and respect_interact_timer:
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
			
			current_input_prompt = signal_name

func _signal_handler(current_signal_string : String, source : Node = null, state_override : String = state_chart.get_current_state().to_lower()) -> void:
	
	var type_suffix : String
	
	match type_selection:
		type.SWITCH:
			type_suffix = "switch"
		type.BUTTON:
			type_suffix = "button"
		type.PROXIMITY:
			type_suffix = "proximity"
	
	## Exclude current state. Used for more general interactions that work both ways e.g. on_area_entered_switch NOT on_area_entered_activated_switch
	var stateless_call_string : String = current_signal_string + "_" + type_suffix
	var stateless_call : Callable = Callable(self, stateless_call_string)
	
	var final_call_string : String = current_signal_string + "_" + state_override + "_" + type_suffix
	var final_call : Callable = Callable(self, final_call_string)
	
	if source:
		final_call = final_call.bind(source)
		stateless_call = stateless_call.bind(source)
	
	if has_method(final_call_string):
		Debug.message(final_call_string)
		final_call.call()
	
	if has_method(stateless_call_string):
		Debug.message(stateless_call_string)
		stateless_call.call()

### --- Signal Handlers --- ###

## State

func _on_state_entered_deactivated() -> void:
	deactivated.emit()
	_signal_handler("_on_state_entered")

func _on_state_exited_deactivated() -> void:
	_signal_handler("_on_state_exited",null,"deactivated")

func _on_state_entered_activated() -> void:
	if is_one_way:
		state_chart.send_event("on_predisabled")
	else:
		activated.emit()
		_signal_handler("_on_state_entered")

func _on_state_exited_activated() -> void:
	_signal_handler("_on_state_exited",null,"activated")

func _on_state_entered_predisabled() -> void:
	one_shot.emit() #Only triggers once per playthrough
	_stop_interact_timer()
	_update_input_prompt(my_component_input_prompt.input_closed)
	state_chart.send_event("on_disabled")

func _on_state_entered_disabled() -> void:
	activated.emit()

## Area

func _on_area_enter(source : Node) -> void:
	_signal_handler("_on_area_enter",source)

func _on_area_interact(source : Node) -> void:
	_signal_handler("_on_area_interact",source)

func _on_area_exit(source : Node) -> void:
	_signal_handler("_on_area_exit",source)

## Timer

func _on_interact_timer_timeout() -> void:
	_signal_handler("_on_interact_timer_timeout")

#### --- Events --- ####

## -- Switch -- ##

# Misc

func _on_interact_timer_timeout_deactivated_switch() -> void:
	_update_input_prompt()

func _on_interact_timer_timeout_activated_switch() -> void:
	_update_input_prompt()

func _on_transition_switch(override : bool = false) -> void:
	
	## Cooldown'd by interact_timer
	if !_is_interact_timer_running() or override:
		state_chart.send_event("on_transition")

# State

func _on_state_entered_activated_switch() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_enter_activated_switch()

func _on_state_entered_deactivated_switch() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_enter_deactivated_switch()

func _on_state_exited_activated_switch() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_exit_activated_switch()
		
	_start_interact_timer()

func _on_state_exited_deactivated_switch() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_exit_deactivated_switch()
	
	_start_interact_timer()

# Area

func _on_area_enter_activated_switch(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_open)

func _on_area_enter_deactivated_switch(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_open)

func _on_area_interact_activated_switch(source : Node = Global.player) -> void:
	_on_transition_switch()

func _on_area_interact_deactivated_switch(source : Node = Global.player) -> void:
	_on_transition_switch()

func _on_area_exit_activated_switch(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_closed)

func _on_area_exit_deactivated_switch(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_closed)

## -- Button -- ##

# Misc

func _on_interact_timer_timeout_deactivated_button() -> void:
	_update_input_prompt()

func _on_transition_button(override : bool = false) -> void:
	
	## Cooldown'd by interact_timer
	if !_is_interact_timer_running() or override:
		state_chart.send_event("on_transition")

# State

func _on_state_entered_activated_button() -> void:
	await interact_timer.timeout
	_on_transition_button()

func _on_state_entered_deactivated_button() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_enter_deactivated_button()

func _on_state_exited_activated_button() -> void:
	_start_interact_timer()

func _on_state_exited_deactivated_button() -> void:
	if !my_component_interact_reciever.get_overlapping_areas().is_empty():
		_on_area_exit_deactivated_button()
	
	_start_interact_timer()

# Area

func _on_area_enter_deactivated_button(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_open)

func _on_area_interact_deactivated_button(source : Node = Global.player) -> void:
	_on_transition_button()

func _on_area_exit_deactivated_button(source : Node = Global.player) -> void:
	_update_input_prompt(my_component_input_prompt.input_closed)

## -- Proximity -- ##

# Area

func _on_area_enter_proximity(source : Node = Global.player) -> void:
	state_chart.send_event("on_activated")

func _on_area_exit_proximity(source : Node = Global.player) -> void:
	state_chart.send_event("on_deactivated")
