extends Node3D

class_name turn_manager2

var new_index : int
var active_character

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	#Init for event bus, so we can recieve char end turn
	Events.turn_end.connect(_on_turn_end)
	#Init for turn list, notifying first turn (change later for speed)
	active_character = get_child(0)
	Events.turn_start.emit(active_character)

func play_turn():
	#Set new character as next in queue, and incrementing the index
	new_index = (active_character.get_index() + 1) % get_child_count()
	active_character = get_child(new_index)
	#Signal to character that it is their turn, and relay all info
	Events.turn_start.emit(active_character)
	#note: for later, add_child() instead of having fixed nodes in manager

func _process(_delta: float) -> void:
	#PLACEHOLDER FOR WHEN MENUS ARE MADE
	if Input.is_action_just_pressed("move_jump"):
		Events.turn_end.emit(active_character)
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_turn_end(_end_character) -> void:
	play_turn()
