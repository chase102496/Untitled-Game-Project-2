extends Node3D

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	#Init for event bus, so we can recieve char end turn
	Events.turn_end.connect(_on_turn_end)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	for i in len(Battle.battle_list):
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.stats.alignment)
		parent.add_child(instance) #Adds it as a child to the position marker
		if instance.stats.alignment == Global.alignment.FOES: #making spacing go opposite
			instance.stats.spacing *= -1
		var offset = instance.stats.spacing #Offset, for more than 1 of the unit we need to move them over some
		instance.position = (offset*i) #Sets position
		
		#FIXME Bandaid solution for state machine being slower than the initialization of my scene so it would not recieve the signal in the right order
		instance.state_init_override = "on_waiting"
		
	Battle.active_character = Battle.battle_list[0] #Setting initial turn order
	
	Battle.active_character.state_init_override = "on_start" #TODO Other bandaid that fits a lil better

func _on_turn_end():
	#Set new character as next in queue, and incrementing the index
	var new_index = (Battle.battle_list.find(Battle.active_character,0) + 1) % len(Battle.battle_list)
	Battle.active_character = Battle.battle_list[new_index]
	Events.turn_start.emit()
	
func _on_battle_finished(outcome):
	if outcome == "Win":
		print_debug("Yay!")
		get_tree().change_scene_to_file("res://scenes/level.tscn")
	elif outcome == "Lose":
		print_debug("womp womp")
		get_tree().change_scene_to_file("res://scenes/level.tscn")

func _physics_process(_delta: float) -> void:
	
	#PLACEHOLDER FOR WHEN MENUS ARE MADE
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/level.tscn")