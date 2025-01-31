extends Node3D

@export var area : Area3D
@export var launch_velocity : Vector3 = Vector3(0,20,0)
@export var launch_velocity_flags : Dictionary = {
	"X" : true,
	"Y" : true,
	"Z" : true
}
@export var add_velocity : bool = true

func _get_launch_target() -> CharacterBody3D:
	for a in area.get_overlapping_areas():
		return Global.find_ancestor_character3d(a)
	
	return

func _launch_target() -> void:
	
	var target = _get_launch_target()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(target,"global_position",area.global_position,0.02)
	
	tween.set_parallel()
	
	var result_velocity : Vector3 = target.velocity
	
	if launch_velocity_flags["X"]:
		result_velocity.x = launch_velocity.x
	if launch_velocity_flags["Y"]:
		result_velocity.y = launch_velocity.y
	if launch_velocity_flags["Z"]:
		result_velocity.z = launch_velocity.z
	
	tween.tween_property(target,"velocity",result_velocity,0.1)
	
	#if add_velocity:
		#_get_launch_target().velocity += launch_velocity
	#else:
		#_get_launch_target().velocity = launch_velocity
