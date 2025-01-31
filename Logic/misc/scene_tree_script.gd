extends Node3D

signal loaded()

@export var emits_loaded_signal: bool = true

@export var scene_type : Global.scene_type

func _init() -> void:
	Global.set_current_scene_type(scene_type)

func _ready() -> void:
	Debug.message(["Scene Loaded ",SceneManager.current_scene],Debug.msg_category.SCENE)

func activate() -> void:
	pass

func load_scene() -> void:
	await get_tree().create_timer(0.5).timeout #cope
	loaded.emit()
	Events.loaded_scene.emit()
