extends Node3D

signal loaded()

@export var emits_loaded_signal: bool = true

@export_enum("world","battle") var scene_type : String = "world"

func _ready() -> void:
	print_debug("Scene Loaded ",SceneManager.current_scene)

func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(0.5).timeout
	loaded.emit()
