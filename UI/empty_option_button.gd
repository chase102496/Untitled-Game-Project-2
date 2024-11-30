extends Button

var option : String
var item : Object
var target : Node

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	text = option

func _on_button_pressed() -> void:
	Events.button_pressed_inventory_item_option.emit(item,option,target)
