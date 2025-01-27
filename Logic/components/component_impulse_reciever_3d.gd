class_name component_impulse_reciever_3d
extends component_node_3d

@export var my_impulse : component_impulse

func _ready() -> void:
	if my_impulse:
		my_impulse.activated.connect(_on_activated)
		my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	pass

func _on_deactivated() -> void:
	pass
