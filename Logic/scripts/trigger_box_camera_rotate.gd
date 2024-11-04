extends Area3D

@export_enum("right","left","back","front") var camera_rotation : String

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D) -> void:
	if body == Global.player:
		Global.camera_function.shot_rotate(camera_rotation)
