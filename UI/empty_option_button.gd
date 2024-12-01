extends Button

var option_path : Array #Keeping track of where we are in options nest
var choices_path : Array #Saving our choices to apply eventually to the script
var item : Object

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	Events.button_pressed_inventory_item_option.emit(item,option_path,choices_path)
