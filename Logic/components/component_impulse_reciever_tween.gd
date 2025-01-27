## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_tween
extends component_impulse_reciever

## This is what we change the variables of when a signal is recieved
@export var my_target : Node = self

@export var tween_trans : Tween.TransitionType
@export var tween_ease : Tween.EaseType

## Turn this off if you want a special duration for the timer, otherwise it will match the time it takes to turn a lever
@export var tween_inherit_interact_timer : bool = true
## Custom time
@export_range(0.0,10.0,0.1) var tween_duration : float = 1.0

@export var dict_activated : Dictionary
@export var dict_deactivated : Dictionary

func _ready() -> void:
	super._ready()
	if my_impulse:
		if tween_inherit_interact_timer and my_impulse.get("interact_timer_max"):
			tween_duration = my_impulse.interact_timer_max

func _on_activated() -> void:
	super._on_activated()
	if !dict_activated.is_empty():
		Global.apply_changes_with_tween(my_target,dict_activated,tween_duration)

func _on_deactivated() -> void:
	super._on_deactivated()
	if !dict_deactivated.is_empty():
		Global.apply_changes_with_tween(my_target,dict_deactivated,tween_duration)
