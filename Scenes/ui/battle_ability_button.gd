extends Button
var ability

var description_box : PanelContainer
var description_label : RichTextLabel
var description_more : String

func _ready() -> void:
	description_box.hide()
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_button_mouse_entered)
	mouse_exited.connect(_on_button_mouse_exited)
	text = str(ability.type.ICON," ",ability.title)

func _on_button_pressed() -> void:
	Events.button_pressed_echoes_ability.emit(ability)

func _on_button_mouse_entered() -> void:
	description_box.show()
	
	description_label.text = str(
		Battle.type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",ability.vis_cost,"  ",Battle.type_color_dict(ability.type),ability.type.ICON,"[/color] ",ability.type.TITLE,"\n",
		ability.description,"\n",
		"\n",
		Battle.type_color("DESCRIPTION"),ability.target_selector.DESCRIPTION,"[/color]","\n",
	)

func _on_button_mouse_exited() -> void:
	description_box.hide()
