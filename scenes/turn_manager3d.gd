extends Node3D

class_name turn_manager2

var new_index : int
var active_character
var battle_list : Array

#Load all units to possibly spawn for battle


#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	
	#Init for event bus, so we can recieve char end turn
	Events.turn_end.connect(_on_turn_end)
	#Init for turn list, notifying first turn (change later for speed)
	active_character = get_child(0)
	Events.turn_start.emit(active_character)
	
	#Initialize gui
	var battle_gui = Battle.main_gui.instantiate()
	add_child(battle_gui)
	
	#Initialize characters
	for i in len(Battle.battle_list_friends):
		var friend_unit = Battle.battle_list_friends[i] #Identifies the unit we are creating
		var anchor = get_node("Anchor_Friends") #Node of relative area of the line they'll spawn in
		var offset = Vector3.ZERO #Offset, for more than 1 of the unit we need to move them over some
		var friend_instance = friend_unit.instantiate() #Creates it
		anchor.add_child(friend_instance) #Adds it as a child to the position marker
		friend_instance.position = anchor.position + offset + Vector3(randf(),randf(),randf()) #Sets position
		#TODO
		friend_instance.state_init_override = "on_start_battle"
		
	for i in len(Battle.battle_list_foes):
		pass #TODO: add battle

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


func _on_ready() -> void:
	pass # Replace with function body.
