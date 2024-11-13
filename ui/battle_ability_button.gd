extends Button
var ability

var description_box : PanelContainer
var description_label : RichTextLabel

func _ready() -> void:
	description_box.hide()
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_button_mouse_entered)
	mouse_exited.connect(_on_button_mouse_exited)
	text = str(ability.type.ICON," ",ability.title)

func _on_button_pressed() -> void:
	Events.battle_gui_button_pressed.emit(ability)

func _on_button_mouse_entered() -> void:
	description_label.text = str(
		"[color=078ef5]◆[/color] ",ability.vis_cost,"  [color=",ability.type.COLOR.to_html(),"]",ability.type.ICON,"[/color] ",ability.type.TITLE,"\n",
		ability.description
	)
	description_box.show()
	
func _on_button_mouse_exited() -> void:
	description_box.hide()
