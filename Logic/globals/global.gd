extends Node
var camera : Node3D = null
var camera_function : Node = null
var camera_object : Node = null
var player : Node3D = null
var state_chart_already_exists : bool = false
var debug = false

func get_glossary_nickname(entity : Node):
	var filepath = entity.get_scene_file_path()
	return filepath.right(-filepath.rfind("/") - 1).left(-5)
