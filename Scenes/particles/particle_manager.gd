class_name particle_manager
extends GPUParticles3D

var queue_buffer : float
	
func _ready() -> void:
	emitting = true
	restart() #Necessary to update one_shot and stuff
	finished.connect.call_deferred(_on_finished)

func _on_finished():
	queue_free()
