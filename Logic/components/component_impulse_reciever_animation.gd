## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_animation
extends component_impulse_reciever

## This is where we recieve our activated and deactivated signals
@export var my_impulse : component_impulse

@export var animation_tree : AnimationTree
@export var animation_state_activated : String = "activated"
@export var animation_state_deactivated : String = "deactivated"

func _ready() -> void:
	if my_impulse:
		my_impulse.activated.connect(_on_activated)
		my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	animation_tree.get("parameters/playback").travel(animation_state_activated)

func _on_deactivated() -> void:
	animation_tree.get("parameters/playback").travel(animation_state_deactivated)
