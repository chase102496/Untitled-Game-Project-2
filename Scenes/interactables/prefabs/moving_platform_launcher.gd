extends Node3D

@export var area : Area3D
@export var launch_velocity : Vector3 = Vector3(0,20,0)
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
	tween.tween_property(target,"velocity",launch_velocity,0.12)
	
	#if add_velocity:
		#_get_launch_target().velocity += launch_velocity
	#else:
		#_get_launch_target().velocity = launch_velocity
