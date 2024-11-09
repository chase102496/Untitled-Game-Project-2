extends Node3D

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	#Init for event bus, so we can recieve char end turn
	Events.turn_end.connect(_on_turn_end)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	var friends_offset := Vector3.ZERO
	var foes_offset := Vector3.ZERO
	for i in len(Battle.battle_list):
		
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.stats.alignment) #Side of the battlefield to spawn on
		parent.add_child(instance) #Adds it as a child to the position marker for our side of battlefield
		
		var tween = get_tree().create_tween()
		
		if instance.stats.alignment == Battle.alignment.FOES:
			instance.position.y = instance.collider.shape.height/2
			tween.tween_property(instance,"position",Vector3(foes_offset.x,instance.position.y,foes_offset.z),0.2)
			foes_offset -= instance.stats.spacing
		else:
			instance.position.y = instance.collider.shape.height/2
			tween.tween_property(instance,"position",Vector3(friends_offset.x,instance.position.y,friends_offset.z),0.2)
			friends_offset += instance.stats.spacing
		
		#FIXME Bandaid solution for state machine being slower than the initialization of my scene so it would not recieve the signal in the right order
		instance.state_init_override = "on_waiting"
		
	Battle.active_character = Battle.battle_list[0] #Setting initial turn order
	
	Battle.active_character.state_init_override = "on_start" #TODO Other bandaid that fits a lil better

func _on_turn_end():
	#Set new character as next in queue, and incrementing the index
	var new_index = (Battle.battle_list.find(Battle.active_character,0) + 1) % len(Battle.battle_list)
	Battle.active_character = Battle.battle_list[new_index]
	Battle.update_positions() #fix positions since we outta queue
	Events.turn_start.emit()
	
func _on_battle_finished(result):
	if result == "Win":
		print_debug("Yay!")
		get_tree().change_scene_to_file("res://levels/dream_garden.tscn")
	elif result == "Lose":
		print_debug("womp womp")
		get_tree().change_scene_to_file("res://levels/dream_garden.tscn")
	else:
		push_error("ERROR")
