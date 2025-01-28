## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_animation
extends component_impulse_reciever

@export var animation_tree : AnimationTree
@export var animation_state_activated : String = "activated"
@export var animation_state_deactivated : String = "deactivated"

func _on_activated() -> void:
	super._on_activated()
	animation_tree.get("parameters/playback").travel(animation_state_activated)

func _on_deactivated() -> void:
	super._on_deactivated()
	animation_tree.get("parameters/playback").travel(animation_state_deactivated)

func _on_one_shot() -> void:
	super._on_one_shot()
	animation_tree.get("parameters/playback").travel(animation_state_activated)
	
