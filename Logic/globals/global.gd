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

## Compares two arrays and returns any matching values between the two
func inner_join(array1: Array, array2: Array) -> Array:
	var matches = []
	for item in array1:
		if item in array2:
			matches.append(item)
	return matches
