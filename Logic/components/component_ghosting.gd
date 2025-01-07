class_name component_ghosting
extends component_node

@export var mesh : MeshInstance3D
@export_range(0, 1, 0.1) var ghosting_strength: float = 0.5

var default_transparency : float = 0

func _ready() -> void:
	if mesh:
		default_transparency = mesh.transparency

func set_ghost(value : bool) -> void:
	if mesh:
		if value:
			mesh.transparency = ghosting_strength
		else:
			mesh.transparency = default_transparency
