## An filter acts as a specialized switch that will carry an impulse if the conditions are met
## Think of it like a combination of a reciever and a controller
class_name component_impulse_filter
extends component_impulse

signal activated
signal deactivated
signal activated_load
signal deactivated_load

@export var my_impulse : component_impulse

## Activates once, and then stays that way
@export var is_one_way : bool = false

## Controls which signals we emit
@export var emission_flags : Dictionary = {
	"activated" : true,
	"deactivated" : true
}

## This will save our last state
## Used to load if we want to save the final state of our system
## A switch cannot know if its conditions were met. A relay is used
## to fire the consequences right after a condition is met.
## So we don't save data in the switch unless there are no conditions
var last_state : String = "_on_deactivated"

func _ready() -> void:
	
	if my_impulse:
		
		## When we're sent an impulse originating from a load
		if my_impulse.get("activated_load"):
			my_impulse.activated_load.connect(_on_my_impulse_activated_load)
		if my_impulse.get("deactivated_load"):
			my_impulse.deactivated_load.connect(_on_my_impulse_deactivated_load)
		
		my_impulse.activated.connect(_on_my_impulse_activated)
		my_impulse.deactivated.connect(_on_my_impulse_deactivated)

func _disconnect() -> void:
	if my_impulse.activated.is_connected(_on_my_impulse_activated):
		my_impulse.activated.disconnect(_on_my_impulse_activated)
	if my_impulse.deactivated.is_connected(_on_my_impulse_deactivated):
		my_impulse.deactivated.disconnect(_on_my_impulse_deactivated)

func _set_load_state(method_name : String) -> void:
	last_state = method_name

##

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
	
	if emission_flags["activated"]:
		
		_set_load_state("_on_activated_load")
		Debug.message([name," _on_activated"],Debug.msg_category.WORLD)
		
		if is_one_way:
			_disconnect()
	
		activated.emit()

func _on_deactivated() -> void:
	
	if emission_flags["deactivated"]:
		
		_set_load_state("_on_deactivated_load")
		Debug.message([name," _on_deactivated"],Debug.msg_category.WORLD)
		
		deactivated.emit()

## Loading signals

func _on_activated_load() -> void:
	
	_set_load_state("_on_activated_load")
	Debug.message([name," _on_activated_load"],Debug.msg_category.WORLD)
	
	if is_one_way:
		_disconnect()
	
	if emission_flags["activated"]:
		activated_load.emit()

func _on_deactivated_load() -> void:
	
	_set_load_state("_on_deactivated_load")
	Debug.message([name," _on_deactivated_load"],Debug.msg_category.WORLD)
	
	if emission_flags["deactivated"]:
		deactivated_load.emit()
