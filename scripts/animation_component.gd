class_name AnimationComponent extends Node

@export var from_center := true
@export var hover_scale := Vector2(1,1)
@export var time := 0.1
@export var transition_type : Tween.TransitionType
#@export var transition_type

var target : Control
var default_scale : Vector2

func _ready() -> void:
	target = get_parent()
	connect_signals()
	call_deferred("setup")

func connect_signals() -> void:
	target.mouse_entered.connect(_on_hover)
	target.mouse_exited.connect(_off_hover)

func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func _off_select() -> void:
	add_tween("scale", default_scale, time)

func _on_hover() -> void:
	add_tween("scale", hover_scale, time)
	
func _off_hover() -> void:
	add_tween("scale", default_scale, time)

func add_tween(property: String, value, seconds: float) -> void:
	if get_tree() != null:
		var tween = get_tree().create_tween()
		tween.tween_property(target, property, value, seconds).set_trans(transition_type)
