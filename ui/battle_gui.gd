extends Control

@onready var ui_grid_main = $Container/Panel1/Main
@onready var ui_grid_battle = $Container/Panel1/Battle
#@onready var ui_grid_switch = $Container/Panel1/Switch
#@onready var ui_grid_item = $Container/Panel1/Item

@onready var ui_button_battle = $Container/Panel1/Main/Battle
@onready var ui_button_switch = $Container/Panel1/Main/Switch
@onready var ui_button_item = $Container/Panel1/Main/Item
@onready var ui_button_escape = $Container/Panel1/Main/Escape

#have it remove the UI when our state is exited
#have it show our state when it is entered

func _ready() -> void:
	hide()
	
	ui_button_battle.pressed.connect(_on_button_pressed_battle)
	ui_button_switch.pressed.connect(_on_button_pressed_switch)
	ui_button_item.pressed.connect(_on_button_pressed_item)
	ui_button_escape.pressed.connect(_on_button_pressed_escape)
	
	#connect to enter and exit for start
	get_parent().state_entered.connect(_on_state_entered)
	get_parent().state_exited.connect(_on_state_exited)

func _on_state_entered():
	#FIXME Just temporary until I make enemies, deleted all other guis
	if Battle.battle_list[0] != owner:
		print('deleted gui: ', self)
		queue_free()
	else:
		show()

func _on_state_exited():
	hide()

func _on_button_pressed_battle():
	print("Battle!!")
	ui_grid_main.hide()
	ui_grid_battle.show()

func _on_button_pressed_switch():
	ui_grid_main.hide()
	#ui_grid_switch.show()
	print("Switch!!")
	
func _on_button_pressed_item():
	ui_grid_main.hide()
	#ui_grid_item.show()
	print("Item!!!")

func _on_button_pressed_escape():
	#send a signal to the player that you wish to escape
	print("Escape :o !!!")

func _process(_delta: float) -> void:
	if Input.is_action_pressed("battle"):
		owner.state_chart.send_event("on_idle") #lol
