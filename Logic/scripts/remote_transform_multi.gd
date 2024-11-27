extends Node3D

@export var watching : Node3D
@export var applying : Node3D
#var offset

func _ready() -> void:
	applying
	pass

func _physics_process(delta: float) -> void:
	for i in applying.size():
		applying1.global_position = watching.global_position.x
