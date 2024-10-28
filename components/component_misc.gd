class_name component_battle_entity
extends Node

func _ready() -> void:
	owner.ready.connect(_on_owner_ready)

func _on_owner_ready() -> void:
	owner.global_position.y = 10
	
