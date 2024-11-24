extends Node3D

signal loaded()

@export var emits_loaded_signal: bool = true

func _ready() -> void:
	print(SceneManager.current_scene)

func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(0.5).timeout
	loaded.emit()
