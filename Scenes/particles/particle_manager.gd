class_name particle_manager
extends GPUParticles3D

var queue_buffer : float

func _enter_tree() -> void:
	emitting = true
	finished.connect(_on_finished)

func _on_finished():
	if one_shot:
		queue_free()
