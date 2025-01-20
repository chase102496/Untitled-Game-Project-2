class_name AnimationComponent extends Node

@export var target : Control
@export var button : Control
@export var from_center := true
@export var hover_scale := Vector2(1,1)
@export var time := 0.1
@export var transition_type : Tween.TransitionType
@export var ease_type : Tween.EaseType

## TBD Delay the signal pressed until after we finish the full press animation
@export var delay_press_signal : bool = true

var default_scale : Vector2

func _ready() -> void:
	
	if !target:
		target = get_parent()
	if !button:
		button = get_parent()
	
	connect_signals()
	setup.call_deferred()

func connect_signals() -> void:
	button.mouse_entered.connect(_on_hover)
	button.mouse_exited.connect(_off_hover)
	button.pressed.connect(_on_pressed)

func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func _off_select() -> void:
	#add_tween("scale", default_scale, time)
	pass

func _on_hover() -> void:
	add_tween("scale", hover_scale, time)
	
func _off_hover() -> void:
	add_tween("scale", default_scale, time)

func add_tween(property: String, value, seconds: float) -> void:
	var tween = self.create_tween()
	if tween:
		tween.tween_property(target, property, value, seconds).set_trans(transition_type).set_ease(ease_type)

func _on_pressed() -> void:
	pass
	#add_tween("scale", hover_scale, time)
