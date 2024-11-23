extends Button
var dreamkin

var description_box : PanelContainer
var description_label : RichTextLabel
signal button_pressed_switch_dreamkin(dreamkin : Object)

func _ready() -> void:
	description_box.hide()
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_button_mouse_entered)
	mouse_exited.connect(_on_button_mouse_exited)
	text = str(dreamkin.type.ICON,dreamkin.name)

func _on_button_pressed() -> void:
	##Validation
	button_pressed_switch_dreamkin.emit(dreamkin)

func _on_button_mouse_entered() -> void:
	description_box.show()
	
	var abil_list = ""
	for i in dreamkin.my_abilities.size():
		abil_list += str(Battle.type_color_dict(dreamkin.my_abilities[i].type),dreamkin.my_abilities[i].type.ICON,"[/color] ",dreamkin.my_abilities[i].title,
		"\n")
	
	description_label.text = str(
		#Battle.type_color_dict(dreamkin.type),dreamkin.type.ICON,"[/color] ",dreamkin.name,"\n",
		Battle.type_color("HEALTH"),Battle.type.HEALTH.ICON,"[/color] ",dreamkin.health,"/",dreamkin.max_health,"  ",
		Battle.type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",dreamkin.vis,"/",dreamkin.max_vis,"\n",
		abil_list
	)

func _on_button_mouse_exited() -> void:
	description_box.hide()
