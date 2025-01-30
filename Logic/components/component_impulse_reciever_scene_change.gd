class_name component_impulse_reciever_scene_change
extends component_impulse_reciever

@export var scene : String
@export var entry_point : Vector3

func _on_activated() -> void:
	super._on_activated()
	
	if entry_point:
		SceneManager.set_entry_point(entry_point)
	
	if scene:
		SceneManager.transition_to(scene)
	else:
		push_error("No scene selected in export window for component_impulse_reciever_scene_change! ",self)
