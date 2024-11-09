extends GPUParticles3D

func _ready() -> void:
	emitting = true
	finished.connect(_on_finished)
	
func _on_finished():
	owner.queue_free()
