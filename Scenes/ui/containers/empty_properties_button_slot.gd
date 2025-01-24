extends Control

@export var button : BaseButton
@export var slot_container : Container

## For general use
var properties : Dictionary = {}

signal button_pressed_properties(properties : Dictionary)
signal button_enter_hover_properties(properties : Dictionary)
signal button_exit_hover_properties(properties : Dictionary)

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)

func _on_button_pressed() -> void:
	button_pressed_properties.emit(properties)

func _on_button_mouse_entered() -> void:
	button_enter_hover_properties.emit(properties)

func _on_button_mouse_exited() -> void:
	button_exit_hover_properties.emit(properties)
