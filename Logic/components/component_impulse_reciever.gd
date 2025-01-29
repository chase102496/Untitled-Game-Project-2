class_name component_impulse_reciever
extends component_node

@export var my_impulse : component_impulse

## This tells us what signals to listen for
@export var my_impulse_flags : Dictionary = {
	"activated" : true,
	"deactivated" : true,
}

## Only triggers once per scene load
@export var is_one_way : bool = false

## Determines how we load back in after is_one_way has been triggered once
@export var one_way_load_behavior : one_way_behavior = one_way_behavior.REPEAT

## STOP is good for items where we don't need them to fire again if they're saved
## REPEAT is good for doors where we need them to run the animation even if they're saved
enum one_way_behavior {
	## We will not run any code if we've already fired once
	STOP,
	## We will re-run any code as if we're being activated again
	REPEAT
}

func _ready() -> void:
	if my_impulse:
		
		## When we're sent an impulse originating from a load
		if my_impulse.get("activated_load"):
			my_impulse.activated_load.connect(_on_activated_load)
		if my_impulse.get("deactivated_load"):
			my_impulse.deactivated_load.connect(_on_deactivated_load)
		
		if my_impulse_flags["activated"]:
			my_impulse.activated.connect(_on_activated)
		if my_impulse_flags["deactivated"]:
			my_impulse.deactivated.connect(_on_deactivated)

func _disconnect() -> void:
	if my_impulse.activated.is_connected(_on_activated):
		my_impulse.activated.disconnect(_on_activated)
	if my_impulse.deactivated.is_connected(_on_deactivated):
		my_impulse.deactivated.disconnect(_on_deactivated)

##

func _on_activated() -> void:
	
	Debug.message([name," _on_activated"],Debug.msg_category.WORLD)
	
	if is_one_way:
		_disconnect()

func _on_deactivated() -> void:
	Debug.message([name," _on_deactivated"],Debug.msg_category.WORLD)

##

func _on_activated_load() -> void:
	if is_one_way:
		Debug.message([name," _on_activated_load"],Debug.msg_category.WORLD)
		
		match one_way_load_behavior:
			
			one_way_behavior.STOP:
				_disconnect()
				
			one_way_behavior.REPEAT:
				_on_activated()
	else:
		_on_activated()

func _on_deactivated_load() -> void:
	
	if is_one_way:
		
		Debug.message([name," _on_deactivated_load"],Debug.msg_category.WORLD)
	
		match one_way_load_behavior:
			
			one_way_behavior.STOP:
				_disconnect()
				
			one_way_behavior.REPEAT:
				_on_deactivated()
	
	else:
		_on_deactivated()
	
	
