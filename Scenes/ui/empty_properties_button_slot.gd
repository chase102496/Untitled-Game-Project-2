extends Control

@export var button : BaseButton
@export var slot_container : MarginContainer

## For general use
var properties : Dictionary = {}

signal button_pressed_properties(properties : Dictionary)
signal button_enter_hover_properties(properties : Dictionary)
signal button_exit_hover_properties(properties : Dictionary)

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	slot_container.child_entered_tree.connect(_on_child_entered_tree)

func _on_button_pressed() -> void:
	button_pressed_properties.emit(properties)

func _on_button_mouse_entered() -> void:
	button_enter_hover_properties.emit(properties)

func _on_button_mouse_exited() -> void:
	button_exit_hover_properties.emit(properties)

## Making sure the icon isn't going to block our mouse
func _on_child_entered_tree(node : Node) -> void:
	Global.set_recursive_property(node,"mouse_filter",MOUSE_FILTER_IGNORE)
