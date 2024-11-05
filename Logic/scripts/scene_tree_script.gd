extends Node3D

func _ready() -> void:
	ready.connect(_on_scene_tree_ready)

func _on_scene_tree_ready():
	Events.scene_tree_ready.emit()
