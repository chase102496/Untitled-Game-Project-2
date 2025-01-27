class_name component_impulse_reciever
extends component_node

@export var my_impulse : component_impulse

## This will only run once per playthrough unless manually reset
@export var flags : Dictionary = {
	"on_one_shot" : false,
	"on_activated" : true,
	"on_deactivated" : false
}

func _ready() -> void:
	if my_impulse:
		my_impulse.one_shot.connect(_on_one_shot)
		my_impulse.activated.connect(_on_activated)
		my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass

func _on_one_shot() -> void:
	pass
