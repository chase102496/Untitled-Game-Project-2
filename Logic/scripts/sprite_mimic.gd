extends AnimatedSprite3D

func _ready() -> void:
	#process_mode =	PROCESS_MODE_DISABLED
	pass

func _physics_process(delta: float) -> void:
	var norm = get_parent()
	sprite_frames = norm.sprite_frames
	animation = norm.animation
	frame = norm.frame
	speed_scale = norm.speed_scale
	modulate = norm.modulate
