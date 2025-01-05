class_name particle_manager
extends GPUParticles3D

func _ready() -> void:
	finished.connect(_on_finished)
	if one_shot:
		emitting = true
	#restart() #?

func _on_finished():
	if one_shot:
		queue_free()
