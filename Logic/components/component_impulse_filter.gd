## An filter acts as a specialized switch that will carry an impulse if the conditions are met
## Think of it like a combination of a reciever and a controller
class_name component_impulse_filter
extends component_impulse

signal activated
signal deactivated
signal activated_load
signal deactivated_load

var current_state : String = "deactivated"

@export var my_impulse : component_impulse

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

## This will save our last state
## Used to load if we want to save the final state of our system
## A switch cannot know if its conditions were met. A relay is used
## to fire the consequences right after a condition is met.
## So we don't save data in the switch unless there are no conditions
var last_state : String = "_on_deactivated"

func _ready() -> void:
	
	Events.loaded_scene.connect(_on_loaded_scene)
	
	_connect_signals()

func _state_transition(state_name : String) -> void:
	if current_state != state_name:
		if is_one_way and one_way_flags["deafen"]:
			_on_impulse_deafen()
	
		if is_one_way and one_way_flags["mute"]:
			_on_impulse_mute()

func _update_signals() -> void:
	if is_deafened:
		_on_impulse_deafen()
	if is_muted:
		_on_impulse_mute()

func _connect_signals() -> void:
	
	if my_impulse:
		
		## When we're sent an impulse originating from a load
		if my_impulse.get("activated_load"):
			my_impulse.activated_load.connect(_on_my_impulse_activated_load)
		if my_impulse.get("deactivated_load"):
			my_impulse.deactivated_load.connect(_on_my_impulse_deactivated_load)
		
		if !my_impulse.activated.is_connected(_on_my_impulse_activated):
			my_impulse.activated.connect(_on_my_impulse_activated)
		if !my_impulse.deactivated.is_connected(_on_my_impulse_deactivated):
			my_impulse.deactivated.connect(_on_my_impulse_deactivated)
	
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
	if my_impulse:
		if my_impulse.activated.is_connected(_on_my_impulse_activated):
			my_impulse.activated.disconnect(_on_my_impulse_activated)
		if my_impulse.deactivated.is_connected(_on_my_impulse_deactivated):
			my_impulse.deactivated.disconnect(_on_my_impulse_deactivated)

func _update_signal_flags() -> void:
	
	if is_deafened or (is_one_way and one_way_flags["deafen"]):
		_on_impulse_deafen()
	
	if is_muted or (is_one_way and one_way_flags["mute"]):
		_on_impulse_mute()

func _on_loaded_scene() -> void:
	_update_signals()

## When we change any state
func _set_load_state(method_name : String) -> void:
	last_state = method_name

## When we send an impulse out to others
func _emit(signal_name : String) -> void:
	if !is_muted:
		get(signal_name).emit()

##

## Completely overrides any function or situation the controller is in, setting it back to default state
func _on_impulse_reset() -> void:
	Debug.message([name," _on_impulse_reset"],Debug.msg_category.WORLD)
	
	if reset_flags["mute"]:
		is_muted = false
	if reset_flags["deafen"]:
		is_deafened = false
		_connect_signals()

func _on_impulse_deafen() -> void:
	Debug.message([name," _on_impulse_deafen"],Debug.msg_category.WORLD)
	_disconnect_signals()
	is_deafened = true

func _on_impulse_mute() -> void:
	Debug.message([name," _on_impulse_mute"],Debug.msg_category.WORLD)
	is_muted = true

## Input

func _on_my_impulse_activated() -> void:
	pass

func _on_my_impulse_deactivated() -> void:
	pass

func _on_my_impulse_activated_load() -> void:
	pass

func _on_my_impulse_deactivated_load() -> void:
	pass

## Output

func _on_activated() -> void:

	
	_set_load_state("_on_activated_load")
	Debug.message([name," _on_activated"],Debug.msg_category.WORLD)
	
	_emit("activated")
	_state_transition.call_deferred("activated")

func _on_deactivated() -> void:
	
	Debug.message([name," _on_deactivated"],Debug.msg_category.WORLD)
	_set_load_state("_on_deactivated_load")
	
	_emit("deactivated")
	_state_transition.call_deferred("deactivated")

## Loading signals

func _on_activated_load() -> void:
	
	Debug.message([name," _on_activated_load"],Debug.msg_category.WORLD)
	_set_load_state("_on_activated_load")
	
	_emit("activated_load")
	_state_transition.call_deferred("activated")

func _on_deactivated_load() -> void:
	
	Debug.message([name," _on_deactivated_load"],Debug.msg_category.WORLD)
	_set_load_state("_on_deactivated_load")
	
	_emit("deactivated_load")
	_state_transition.call_deferred("deactivated")
