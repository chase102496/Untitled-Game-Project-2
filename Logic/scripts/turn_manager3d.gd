extends Node3D

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	#Init for event bus, so we can recieve char end turn
	Events.battle_entity_death.connect(_on_battle_entity_death)
	Events.turn_end.connect(_on_turn_end)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	var friends_offset := Vector3.ZERO
	var foes_offset := Vector3.ZERO
	for i in len(Battle.battle_list):
		
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.alignment) #Side of the battlefield to spawn on
		parent.add_child(instance) #Adds it as a child to the position marker for our side of battlefield
		
		var tween = get_tree().create_tween()
		
		if instance.alignment == Battle.alignment.FOES:
			instance.position.y = instance.collider.shape.height/2
			tween.tween_property(instance,"position",Vector3(foes_offset.x,instance.position.y,foes_offset.z),0.2)
			foes_offset -= instance.spacing
		else:
			instance.position.y = instance.collider.shape.height/2
			tween.tween_property(instance,"position",Vector3(friends_offset.x,instance.position.y,friends_offset.z),0.2)
			friends_offset += instance.spacing
		
		#FIXME Bandaid solution for state machine being slower than the initialization of my scene so it would not recieve the signal in the right order
		instance.state_init_override = "on_waiting"
		
	Battle.active_character = Battle.battle_list[0] #Setting initial turn order
	
	Battle.active_character.state_init_override = "on_start" #TODO Other bandaid that fits a lil better
	
	Battle.update_positions()

func _on_battle_entity_death(entity : Node) -> void:
	
	if Battle.active_character == entity:
		Events.turn_end.emit()
	
	if len(Battle.my_team(entity)) == 1: #If this is the last on its team when it dies
		if entity.alignment == Battle.alignment.FOES:
			Events.battle_finished.emit("Win")
		elif entity.alignment == Battle.alignment.FRIENDS:
			Events.battle_finished.emit("Lose")
		else:
			push_error("ERROR")
		
		Battle.battle_list.pop_at(Battle.battle_list.find(entity,0)) #remove us from queue
	else:
		Battle.battle_list.pop_at(Battle.battle_list.find(entity,0)) #remove us from queue
		entity.my_component_ability.current_status_effects.status_event("on_death") #trigger on death for all status stuff
	
	Battle.update_positions() #fix positions since we outta queue
	entity.queue_free() #deletus da fetus

func _on_turn_end() -> void:
	#Set new character as next in queue, and incrementing the index
	var old_character = Battle.active_character
	var new_index = (Battle.battle_list.find(Battle.active_character,0) + 1) % len(Battle.battle_list)
	Battle.active_character = Battle.battle_list[new_index]
	var new_character = Battle.active_character
	
	if old_character.alignment != new_character.alignment: #If we are now on the other team's turn sequence
		Events.battle_team_start.emit(new_character.alignment)
	
	Events.turn_start.emit()
	
func _on_battle_finished(result) -> void:
	if result == "Win":
		PlayerData.save_data_scene()
		print_debug("Yay!")
		get_tree().change_scene_to_file("res://Levels/dream_garden.tscn")
	elif result == "Lose":
		PlayerData.save_data_scene()
		print_debug("womp womp")
		get_tree().change_scene_to_file("res://Levels/dream_garden.tscn")
	else:
		push_error("ERROR")
