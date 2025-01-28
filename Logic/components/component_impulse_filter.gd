## An filter acts as a specialized switch that will carry an impulse if the conditions are met
## Think of it like a combination of a reciever and a controller
class_name component_impulse_filter
extends component_impulse

signal activated
signal deactivated
signal one_shot

@export var my_impulse : component_impulse

## This tells us what signals to listen for
## on_one_shot will only trigger if our impulse signal we recieve is set to one_shot
## What this will do is tell us which signals to listen from our parent
## This changes what each reciever does
@export var my_impulse_flags : Dictionary = {
	"on_one_shot" : false,
	"on_activated" : true,
	"on_deactivated" : false
}

## Once activated normally, it will stay on forever
@export var is_one_way : bool = false

func _ready() -> void:
	
	activated.connect(_on_activated)
	deactivated.connect(_on_deactivated)
	
	if my_impulse:
		if my_impulse_flags.on_one_shot:
			my_impulse.one_shot.connect(_on_my_impulse_one_shot)
		if my_impulse_flags.on_activated:
			my_impulse.activated.connect(_on_my_impulse_activated)
		if my_impulse_flags.on_deactivated:
			my_impulse.deactivated.connect(_on_my_impulse_deactivated)

func _on_activated() -> void:
	if is_one_way:
		if my_impulse.on_one_shot.is_connected():
			my_impulse.one_shot.disconnect(_on_my_impulse_one_shot)
		if my_impulse.on_activated.is_connected():
			my_impulse.activated.disconnect(_on_my_impulse_activated)
		if my_impulse.on_deactivated.is_connected():
			my_impulse.deactivated.disconnect(_on_my_impulse_deactivated)

func _on_deactivated() -> void:
	pass

func _on_my_impulse_activated() -> void:
	pass

func _on_my_impulse_deactivated() -> void:
	pass

func _on_my_impulse_one_shot() -> void:
	pass
