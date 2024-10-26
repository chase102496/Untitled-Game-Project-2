extends Button
var ability

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_button_pressed)
	text = str(ability.type.ICON," ",ability.title)
	# vis cost
	# element
	# description
	# etc
	#TODO Make a tooltip when you hover over the button for all the relevant ability info above (?) NO, just damage and vis

func _on_button_pressed():
	#send message to owner what 
	Events.battle_gui_button_pressed.emit(ability)
