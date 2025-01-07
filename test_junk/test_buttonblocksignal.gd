extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	set_block_signals(true)
