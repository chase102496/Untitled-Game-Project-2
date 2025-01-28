class_name component_impulse_reciever_3d
extends component_node_3d

@export var my_impulse : component_impulse

## This tells us what signals to listen for
## on_one_shot will only trigger if our impulse signal has is_one_way == true
@export var my_impulse_flags : Dictionary = {
	"on_one_shot" : false,
	"on_activated" : true,
	"on_deactivated" : false
}

## Only triggers once
@export var is_one_way : bool = false

func _ready() -> void:
	if my_impulse:
		if my_impulse_flags.on_one_shot:
			my_impulse.one_shot.connect(_on_one_shot)
		if my_impulse_flags.on_activated:
			my_impulse.activated.connect(_on_activated)
		if my_impulse_flags.on_deactivated:
			my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

func _on_one_shot() -> void:
	pass
