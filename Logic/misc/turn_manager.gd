extends Node3D

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

## Makes sure no matter what, when we unload the battlefield the Battle list is cleared
func _exit_tree() -> void:
	Battle.battle_list.clear()

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	
	#Init for event bus, so we can recieve char end turn
	Events.battle_entity_death.connect(_on_battle_entity_death)
	Events.turn_end.connect(_on_turn_end)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	var friends_offset := Vector3.ZERO
	var foes_offset := Vector3.ZERO
	
	for i in Battle.battle_list.size():
		
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
		
		if i != 0:
			instance.state_chart.send_event.call_deferred("on_waiting")
		else:
			instance.state_chart.send_event.call_deferred("on_start")
			Battle.active_character = instance
			Battle.active_character_index = 0
	
	Battle.update_positions.call_deferred()
	
	Battle.camera_update()

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
		entity.my_component_ability.my_status.status_event("on_death") #trigger on death for all status stuff
	
	entity.queue_free() #deletus da fetus
	Battle.update_positions() #fix positions since we outta queue

func _on_turn_end() -> void:
	#Set new character as next in queue, and incrementing the index
	var old_character = Battle.active_character
	var old_index = Battle.active_character_index
	var new_index
	
	Debug.message(["Ending turn for ",old_character.name],Debug.msg_category.BATTLE)
	
	#Validation check
	if Battle.battle_list.find(old_character) == -1: #If we cannot find the old active character in the list,
		new_index = (old_index + 1) % Battle.battle_list.size()
		Battle.active_character = Battle.battle_list[new_index]
	else:
		new_index = (Battle.battle_list.find(Battle.active_character,0) + 1) % Battle.battle_list.size()
	
	#Updating active index and character
	Battle.active_character_index = new_index
	Battle.active_character = Battle.battle_list[new_index]

	#If we are now on the other team's turn sequence
	if old_character.alignment != Battle.active_character.alignment:
		Events.battle_team_start.emit(Battle.active_character.alignment)
	
	Debug.message(["Starting turn for ",Battle.active_character.name],Debug.msg_category.BATTLE)
	
	Events.turn_start.emit() #Sends everyone a memo that there's a new turn
	
	Battle.camera_update()

func _on_battle_finished(result) -> void:
	if result == "Win":
		SaveManager.save_data_session()
		Debug.message("Result = Win!",Debug.msg_category.BATTLE)
		SceneManager.transition_to("res://Levels/dream_garden.tscn")
	elif result == "Lose":
		SaveManager.save_data_session()
		Debug.message("Result = Lose!",Debug.msg_category.BATTLE)
		SceneManager.transition_to("res://Levels/dream_garden.tscn")
	else:
		push_error("Unknown result ",result)
