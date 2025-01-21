extends AnimationPlayer

@export var autoplay_animation : String

func _ready() -> void:
	if autoplay_animation:
		play(autoplay_animation)
