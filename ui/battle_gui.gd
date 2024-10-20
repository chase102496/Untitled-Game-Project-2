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
	#connect to button signals
	ui_button_battle.pressed.connect(_on_button_pressed_battle)
	
	# TODO Sets up our abilities in the ui
	#for i in $Container/Panel1/Battle.get_child_count():
		#ui_grid_battle.get_child(i).text = get_parent().my_abilities[i]

	#
	ui_button_switch.pressed.connect(_on_button_pressed_switch)
	#
	ui_button_item.pressed.connect(_on_button_pressed_item)
	#
	ui_button_escape.pressed.connect(_on_button_pressed_escape)
	#
	#connect to enter and exit for start
	$"../StateChart/Main/Battle/Start".state_entered.connect(_on_state_entered_battle_start)
	$"../StateChart/Main/Battle/Start".state_exited.connect(_on_state_exited_battle_start)

func _on_state_entered_battle_start():
	#FIXME just for demonstration
	if owner == Battle.battle_list[0]:
		show()
	else:
		queue_free()

func _on_state_exited_battle_start():
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
	pass
