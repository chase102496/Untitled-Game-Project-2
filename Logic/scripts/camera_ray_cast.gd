extends RayCast3D

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var offset = Global.player.global_position.direction_to(owner.global_position).normalized()
	#var target_relative = owner.global_position - (Global.player.global_position + offset)
	set_target_position(offset) #We're just gonna leave my broken ass code idgaf
