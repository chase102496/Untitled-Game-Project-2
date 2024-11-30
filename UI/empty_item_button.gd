extends Button

var item

@onready var description_sprite #= blah

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_button_mouse_entered)
	mouse_exited.connect(_on_button_mouse_exited)
	text = str(item.title,"  x",item.quantity)

func _on_button_pressed() -> void:
	Events.button_pressed_inventory_item.emit(item)

func _on_button_mouse_entered() -> void:
	Events.mouse_entered_inventory_item.emit(item)

func _on_button_mouse_exited() -> void:
	Events.mouse_exited_inventory_item.emit(item)
