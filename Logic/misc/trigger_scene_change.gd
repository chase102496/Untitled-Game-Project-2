extends Area3D

@export var scene : String
@export var entry_point : Vector3

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node3D):
	if body == Global.player:
		if entry_point:
			SceneManager.set_entry_point(entry_point)
		if scene:
			SceneManager.transition_to(scene)
		else:
			push_error("No scene selected in export window")
