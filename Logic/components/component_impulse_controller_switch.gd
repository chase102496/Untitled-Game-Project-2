## A user-input switch that toggles from activated to deactivated
class_name component_impulse_controller_switch
extends component_impulse_controller

signal activated
signal deactivated
signal activated_load
signal deactivated_load

##Determines how this switch operates
@export var type_selection : type = type.SWITCH
## The way interaction is handled
enum type {
	## Like a lever. Toggles between activated and deactivated on interaction
	SWITCH,
	## Like a pressure plate. Activates when in its Area3D, and deactivates upon exiting.
	PROXIMITY,
	## Like a button. Triggers once, then goes immediately back to deactivated after a short cooldown
	BUTTON
}

@export_category("One way")

## Mute or deafen signals for us when we change states from default
@export var is_one_way : bool = false
## Controls what happens when we trigger one_way
@export var one_way_flags : Dictionary = {
	"deafen" : true,
	"mute" : true
}

@export_category("Reset")

## If we recieve activated from this, we reset our controller signals based on flags
@export var impulse_reset : component_impulse
@export var impulse_reset_signal : String = "activated"
## Controls which signals we reset
@export var reset_flags : Dictionary = {
	"deafen" : true,
	"mute" : true
}

@export_category("Deafen")

## If plugged in, recieving a signal from this will completely deafen us
@export var impulse_deafen : component_impulse
@export var impulse_deafen_signal : String = "activated"
@export var is_deafened : bool = false

@export_category("Mute")

## If plugged in, recieving a signal from this will completely mute us
@export var impulse_mute : component_impulse
@export var impulse_mute_signal : String = "activated"
@export var is_muted : bool = false

@export_category("Misc")

## The delay after changing states before we can do it again
var interact_timer : Timer = Timer.new()
@export_range(0.1,10,0.1) var interact_timer_max : float = 0.25

## The input prompt to signal to
@export var my_component_input_prompt : component_input_prompt

## This is what we get our signals from, usually an Area3D
@onready var my_component_interact_reciever : component_interact_reciever = get_my_component_interact_reciever()

##
@onready var state_chart : StateChart = $StateChart

##
#@onready var state_chart_initial_state = $StateChart/Main.initial_state

func _ready() -> void:
	
	interact_timer.one_shot = true
	add_child(interact_timer)
	interact_timer.timeout.connect(_on_interact_timer_timeout)
	
	## States
	$StateChart.state_changed.connect(_on_state_changed)
	$StateChart/Main/Deactivated.state_entered.connect(_on_state_entered_deactivated)
	$StateChart/Main/Deactivated.state_exited.connect(_on_state_exited_deactivated)
	$StateChart/Main/Activated.state_entered.connect(_on_state_entered_activated)
	$StateChart/Main/Activated.state_exited.connect(_on_state_exited_activated)
	$StateChart/Main/PreDisabled.state_entered.connect(_on_state_entered_predisabled)
	$StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	
	_connect_signals()
	
	Events.loaded_scene.connect(_on_loaded_scene)

## General Utility

func _update_signals() -> void:
	if is_deafened:
		_on_impulse_deafen()
	if is_muted:
		_on_impulse_mute()

## Used for setting us up like we were first instantiated
func _connect_signals() -> void:
	
	## Reciever
	if my_component_interact_reciever:
		if !my_component_interact_reciever.enter.is_connected(_on_area_enter):
			my_component_interact_reciever.enter.connect(_on_area_enter)
		if !my_component_interact_reciever.interact.is_connected(_on_area_interact):
			my_component_interact_reciever.interact.connect(_on_area_interact)
		if !my_component_interact_reciever.exit.is_connected(_on_area_exit):
			my_component_interact_reciever.exit.connect(_on_area_exit)
	else:
		push_warning("No component_interact_reciever attached to controller: ",self.name," ",self)
	
	## NOTE : If both impulse_reset and impulse_disable are the same source, it will reset and THEN disable
	
	## Reset
	if impulse_reset and !impulse_reset.is_connected(impulse_reset_signal,_on_impulse_reset):
		impulse_reset.connect(impulse_reset_signal,_on_impulse_reset)
	
	## Mute
	if impulse_mute and !impulse_mute.is_connected(impulse_mute_signal,_on_impulse_mute):
		impulse_mute.connect(impulse_mute_signal,_on_impulse_mute)
	
	## Deafen
	if impulse_deafen and !impulse_deafen.is_connected(impulse_deafen_signal,_on_impulse_deafen):
		impulse_deafen.connect(impulse_deafen_signal,_on_impulse_deafen)

func _disconnect_signals() -> void:
	
	if my_component_interact_reciever:
		
		if my_component_interact_reciever.enter.is_connected(_on_area_enter):
			my_component_interact_reciever.enter.disconnect(_on_area_enter)
		if my_component_interact_reciever.interact.is_connected(_on_area_interact):
			my_component_interact_reciever.interact.disconnect(_on_area_interact)
		if my_component_interact_reciever.exit.is_connected(_on_area_exit):
			my_component_interact_reciever.exit.disconnect(_on_area_exit)
	else:
		push_warning("No component_interact_reciever attached to controller: ",self.name," ",self)

func get_my_component_interact_reciever():
	for child in get_children():
		if child is component_interact_reciever:
			return child
	
	push_error("Could not find component_interact_reciever for ",name," in ",get_parent())

## Signal Mods

func _on_loaded_scene() -> void:
	_update_signals()

## When we send an impulse out to others
func _emit(signal_name : String) -> void:
	if !is_muted:
		get(signal_name).emit()

## Completely overrides any function or situation the controller is in, setting it back to default state
func _on_impulse_reset() -> void:
	Debug.message([name," _on_impulse_reset"],Debug.msg_category.WORLD)
	
	if reset_flags["mute"]:
		is_muted = false
	if reset_flags["deafen"]:
		is_deafened = false
		_connect_signals()
	
	state_chart.send_event("_on_reset")

func _on_impulse_deafen() -> void:
	Debug.message([name," _on_impulse_deafen"],Debug.msg_category.WORLD)
	_disconnect_signals()
	is_deafened = true

func _on_impulse_mute() -> void:
	Debug.message([name," _on_impulse_mute"],Debug.msg_category.WORLD)
	is_muted = true

## Interact Timer

func _start_interact_timer() -> void:
	interact_timer.start(interact_timer_max)

func _stop_interact_timer() -> void:
	interact_timer.stop()

func _is_interact_timer_running() -> bool:
	return !interact_timer.is_stopped()

## Meat and Potatoes Functions

## Keeps track of input prompt when it isn't displayed to update it later
var current_input_prompt : Signal

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

## Calls the correct sub-signal based on our type
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

func _transition(state_name : String) -> void:
	state_chart.send_event(state_name)

func _on_state_changed(event : StringName = "") -> void:
	
	_update_input_prompt(my_component_input_prompt.input_closed)
	
	if is_one_way and one_way_flags["deafen"]:
		_on_impulse_deafen()
	
	if is_one_way and one_way_flags["mute"]:
		_on_impulse_mute()

func _on_state_entered_deactivated() -> void:
	_emit("deactivated")
	_signal_handler("_on_state_entered")

func _on_state_exited_deactivated() -> void:
	_signal_handler("_on_state_exited",null,"deactivated")

func _on_state_entered_activated() -> void:
	_emit("activated")
	_signal_handler("_on_state_entered")
	
	#if is_one_way:
		#state_chart.send_event("on_predisabled")
	#else:

func _on_state_exited_activated() -> void:
	_signal_handler("_on_state_exited",null,"activated")

var is_player_source : bool = false
func _on_state_entered_predisabled() -> void:
	activated.emit()
	is_player_source = true
	_stop_interact_timer()
	_update_input_prompt(my_component_input_prompt.input_closed)
	state_chart.send_event("on_disabled")

func _on_state_entered_disabled() -> void:
	if !is_player_source:
		activated_load.emit()

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
		_transition("on_transition")

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
		_transition("on_transition")

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
	_transition("on_activated")

func _on_area_exit_proximity(source : Node = Global.player) -> void:
	_transition("on_deactivated")
