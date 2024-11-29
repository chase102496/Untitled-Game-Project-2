extends Button
var item

var description_box : PanelContainer
var description_label : RichTextLabel

@onready var description_sprite #= blah

func _ready() -> void:
	description_box.hide()
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_button_mouse_entered)
	mouse_exited.connect(_on_button_mouse_exited)
	text = str(item.title)

func _on_button_pressed() -> void:
	Events.button_pressed_inventory_item.emit(item)

func _on_button_mouse_entered() -> void:
	description_box.show()

	#show sprite here
	
	description_label.text = str("eee")

func _on_button_mouse_exited() -> void:
	description_box.hide()
