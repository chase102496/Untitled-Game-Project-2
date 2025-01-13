class_name particle_manager
extends GPUParticles3D

func _enter_tree() -> void:
	emitting = true

func _ready() -> void:
	finished.connect(_on_finished)

func _on_finished():
	if one_shot:
		queue_free()
