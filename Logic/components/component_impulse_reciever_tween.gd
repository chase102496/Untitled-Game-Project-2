## Attach this component and then specify which values you want to toggle for activated and deactivated in export
class_name component_impulse_reciever_tween
extends component_impulse_reciever

## This is where we recieve our activated and deactivated signals
@export var my_impulse : component_impulse

## This is what we change the variables of when a signal is recieved
@export var my_target : Node = self

@export var tween_trans : Tween.TransitionType
@export var tween_ease : Tween.EaseType
@export_range(0.0,10.0,0.1) var tween_duration : float = 1.0
@export var dict_activated : Dictionary
@export var dict_deactivated : Dictionary

func _ready() -> void:
	if my_impulse:
		my_impulse.activated.connect(_on_activated)
		my_impulse.deactivated.connect(_on_deactivated)

func _on_activated() -> void:
	if !dict_activated.is_empty():
		Global.apply_changes_with_tween(my_target,dict_activated,tween_duration)

func _on_deactivated() -> void:
	if !dict_deactivated.is_empty():
		Global.apply_changes_with_tween(my_target,dict_deactivated,tween_duration)
