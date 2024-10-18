extends Node3D

class_name turn_manager2

var new_index : int
var active_character

@onready var ui_grid_main = get_node("../Battle_GUI/Container/Panel1/Main")

@onready var ui_grid_battle = get_node("../Battle_GUI/Container/Panel1/Battle")
#@onready var ui_grid_switch = get_node("../Battle_GUI/Container/Panel1/Switch")
#@onready var ui_grid_item = get_node("../Battle_GUI/Container/Panel1/Item")

@onready var ui_button_battle = get_node("../Battle_GUI/Container/Panel1/Main/Battle")
@onready var ui_button_switch = get_node("../Battle_GUI/Container/Panel1/Main/Switch")
@onready var ui_button_item = get_node("../Battle_GUI/Container/Panel1/Main/Item")
@onready var ui_button_escape = get_node("../Battle_GUI/Container/Panel1/Main/Escape")

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	
	#Init for turn list, notifying first turn (change later for speed)
	active_character = get_child(0)
	#Init for event bus, so we can recieve char end turn
	Events.turn_end.connect(_on_turn_end)
	#Let the initial character know it's their turn
	Events.turn_start.emit(active_character)
	#Init for buttons to interact with menu
	ui_button_battle.pressed.connect(_on_button_pressed_battle)
	ui_button_switch.pressed.connect(_on_button_pressed_switch)
	ui_button_item.pressed.connect(_on_button_pressed_item)
	ui_button_escape.pressed.connect(_on_button_pressed_escape)

	#HACK
	#var button_test = Label.new() #This is how to add a new part to ui live
	#button_test.text = "test"
	#column1.add_child(button_test)

	#Initialize characters and battle list
	for i in len(Battle.battle_list):
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.stats.alignment)
		parent.add_child(instance) #Adds it as a child to the position marker
		var offset = instance.stats.spacing #Offset, for more than 1 of the unit we need to move them over some
		instance.position = (offset*i) #Sets position
		
		#FIXME Bandaid solution for state machine being slower than the initialization of my scene so it would not recieve the signal in the right order
		instance.state_init_override = "on_start_battle"

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

func play_turn():
	#Set new character as next in queue, and incrementing the index
	new_index = (active_character.get_index() + 1) % get_child_count()
	active_character = get_child(new_index)
	#Signal to character that it is their turn, and relay all info
	Events.turn_start.emit(active_character)
	#note: for later, add_child() instead of having fixed nodes in manager

func _physics_process(_delta: float) -> void:
	
	#PLACEHOLDER FOR WHEN MENUS ARE MADE
	if Input.is_action_just_pressed("move_jump"):
		Events.turn_end.emit(active_character)
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_turn_end(_end_character) -> void:
	play_turn()
