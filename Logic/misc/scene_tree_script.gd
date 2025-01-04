extends Node3D

signal loaded()

@export var emits_loaded_signal: bool = true

@export_enum("world","battle") var scene_type : String = "world"

func _ready() -> void:
	Debug.message(["Scene Loaded ",SceneManager.current_scene],Debug.msg_category.SCENE)

func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(0.5).timeout
	loaded.emit()
