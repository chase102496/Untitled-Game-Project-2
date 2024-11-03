extends RayCast3D

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var offset = Global.player.global_position.direction_to(global_position).normalized()
	var target_relative = global_position - (Global.player.global_position + offset)
	set_target_position(target_relative)
