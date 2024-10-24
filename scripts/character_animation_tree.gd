extends AnimationTree

func _on_animation_finished(anim_name: StringName) -> void:
	Events.animation_finished.emit(anim_name,owner)

func _on_animation_started(anim_name: StringName) -> void:
	Events.animation_started.emit(anim_name,owner)
