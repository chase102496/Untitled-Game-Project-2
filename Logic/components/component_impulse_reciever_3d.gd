class_name component_impulse_reciever_3d
extends component_node_3d

@export var my_impulse : component_impulse

## This tells us what signals to listen for
@export var my_impulse_flags : Dictionary = {
	"activated" : true,
	"deactivated" : true
}

## Only triggers once
@export var is_one_way : bool = false

func _ready() -> void:
	if my_impulse:
		if my_impulse_flags["activated"]:
			my_impulse.activated.connect(_on_activated)
		if my_impulse_flags["deactivated"]:
			my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	
	Debug.message([name," _on_activated"],Debug.msg_category.WORLD)
	
	if is_one_way:
		if my_impulse.activated.is_connected(_on_activated):
			my_impulse.activated.disconnect(_on_activated)
		if my_impulse.deactivated.is_connected(_on_deactivated):
			my_impulse.deactivated.disconnect(_on_deactivated)

func _on_deactivated() -> void:
	Debug.message([name," _on_deactivated"],Debug.msg_category.WORLD)
