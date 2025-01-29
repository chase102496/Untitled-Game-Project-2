## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_animation
extends component_impulse_reciever

@export var animation_tree : AnimationTree
@export var animation_state_activated : String = "activated"
@export var animation_state_deactivated : String = "deactivated"
#
@export_range(-10,10,0.1) var playback_speed_activated : float = 1
@export_range(-10,10,0.1) var playback_speed_deactivated : float = 1
@export var use_reverse_activated_as_deactivated : bool = false

func _on_activated() -> void:
	super._on_activated()

	animation_tree.get("parameters/playback").travel(animation_state_activated)
	animation_tree.set("parameters/activated/TimeScale/scale",playback_speed_activated)

func _on_deactivated() -> void:
	super._on_deactivated()
	if use_reverse_activated_as_deactivated:
		animation_tree.get("parameters/playback").travel("activated_clone")
		animation_tree.set("parameters/activated_clone/TimeScale/scale",-playback_speed_activated)
	else:
		animation_tree.get("parameters/playback").travel(animation_state_deactivated)
		animation_tree.set("parameters/deactivated/TimeScale/scale",playback_speed_deactivated)
