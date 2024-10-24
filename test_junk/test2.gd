extends Node3D
func _ready() -> void:
	_set_viewport_mat($MeshInstance3D,$SubViewport)
func _set_viewport_mat(_display_mesh : MeshInstance3D, _sub_viewport : SubViewport, _surface_id : int = 0):
	var _mat : StandardMaterial3D = StandardMaterial3D.new()
	_mat.albedo_texture = _sub_viewport.get_texture()
	_display_mesh.set_surface_override_material(_surface_id, _mat)
