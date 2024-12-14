extends Node3D

func _ready() -> void:
	#$component_interact_reciever.enter.connect(_on_enter)
	$component_interact_reciever.interact.connect(_on_interact)

func _on_interact(source : Node) -> void:
	pass
