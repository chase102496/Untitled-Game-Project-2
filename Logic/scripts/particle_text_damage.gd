extends GPUParticles3D

var creator : Node #Who created us?

func _ready() -> void:
	emitting = true
	one_shot = true
	finished.connect(_on_finished)
	
func _on_finished():
	owner.queue_free()
