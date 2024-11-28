extends PathFollow3D

var bottom
var top
var anchor

func _ready() -> void:
	anchor = get_parent().global_position
	top = get_parent().curve.get_point_position(0) + anchor#Get first point in path
	bottom = get_parent().curve.get_point_position(1) + anchor#Get last point in path

func _physics_process(delta: float) -> void:
	var follow = Global.player.global_position
	var result = clamp(follow.x,bottom.x,top.x)
	global_position.x = result
