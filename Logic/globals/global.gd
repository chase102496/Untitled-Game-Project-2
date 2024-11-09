extends Node
var camera : Node3D = null
var camera_function : Node = null
var camera_object : Node = null
var player : Node3D = null
var state_chart_already_exists : bool = false
var debug = false

func _ready() -> void:
	Events.scene_tree_ready.connect(_on_scene_tree_ready)

func _on_scene_tree_ready() -> void:
	pass

func scene_transition(scene : NodePath) -> void:
	print_debug(scene)
