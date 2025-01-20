extends Area3D

@export_enum("west","east","south","north") var camera_rotation : String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D) -> void:
	if body == Global.player:
		Global.camera_function.shot_rotate(camera_rotation)
