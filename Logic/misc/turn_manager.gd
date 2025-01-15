extends Node3D

@export var spotlight : BattleSpotlight

#ability queue = []
#add an object, their function, and args
#the function added to queue should always call queue_next at the end to specify it is finished
#the turn manager will then move the queue along

#DO NOT PUT ANYTHING BESIDES THE UNITS THAT WILL BE FIGHTING AND TAKING TURNS IN THE IMMEDIATE CHILD SECTION OF TURN_MANAGER

## Makes sure no matter what, when we unload the battlefield the Battle list is cleared
func _exit_tree() -> void:
	Battle.battle_list.clear()

#Init and set active character to the first in our child list and emit start of turn
func _ready() -> void:
	#Setting current spotlight for reference in Battle
	Battle.battle_spotlight = spotlight
	
	#Init for event bus, so we can recieve char end turn
	Events.battle_entity_dying.connect(_on_battle_entity_dying)
	Events.battle_entity_death.connect(_on_battle_entity_death)
	Events.turn_end.connect(_on_turn_end)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	for i in Battle.battle_list.size():
		
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.alignment) #Side of the battlefield to spawn on
		parent.add_child(instance) #Adds it as a child to the position marker for our side of battlefield
		
		Battle.update_positions.call_deferred()
		
		if i != 0:
			instance.state_chart.send_event.call_deferred("on_waiting")
		else:
			instance.state_chart.send_event.call_deferred("on_start")
			Battle.active_character = instance
			Battle.active_character_index = 0
	
	Battle.update_positions.call_deferred()
	
	Battle.camera_update()

func _on_battle_entity_dying(entity : Node) -> void:
	
	Debug.message("Handling dying entity...",Debug.msg_category.BATTLE)
	
	if Battle.active_character == entity:
		Events.turn_end.emit()
		Battle.orphan_battle_spotlight()

func _is_battle_over() -> bool:
	if Battle.get_team(Battle.alignment.FRIENDS).size() == 0:
		Events.battle_finished.emit("Lose")
		return true
	elif Battle.get_team(Battle.alignment.FOES).size() == 0:
		Events.battle_finished.emit("Win")
		return true
	else:
		return false

func _on_battle_entity_death(entity : Node) -> void:
	
	Debug.message("Handling dead entity...",Debug.msg_category.BATTLE)
	
	 #trigger on death for all status stuff
	Battle.battle_list[Battle.battle_list.find(entity)] = null
	
	## Remove them from the world
	entity.queue_free()

func _on_turn_end() -> void:
	
	Debug.message("Ending turn...",Debug.msg_category.BATTLE)
	
	await get_tree().create_timer(0.3).timeout
	
	## If someone is ready to DIE
	if !Battle.death_queue.is_empty():
		Debug.message("Death queue has entities...",Debug.msg_category.BATTLE)
		Battle.run_death_queue()
		_on_turn_end()
	## If someone isn't ready for whatever reason, rerun this
	elif !Battle.check_ready():
		Debug.message("Waiting for all entities to be ready...",Debug.msg_category.BATTLE)
		_on_turn_end()
	else:
		Debug.message("Signaling next turn...",Debug.msg_category.BATTLE)
		_next_turn()

## Find the next value in the array past the current index. If it's null, keep adding one and looping until it isn't null
func _find_next_valid_character(old_index : int):
	
	## Checking size to make sure it's good enough
	if Battle.battle_list.size() == 0:
		Debug.message("Battle list is empty!", Debug.msg_category.BATTLE)
		return -1
	
	for i in Battle.battle_list.size():
		## Setting it to a new val
		var new_index = (old_index + 1 + i) % Battle.battle_list.size()
		var character = Battle.battle_list[new_index]
		
		## If it's null, try again
		if !character:
			Debug.message("Previous character died, cycling to next...",Debug.msg_category.BATTLE)
		else:
			Debug.message(["Setting next active character..."],Debug.msg_category.BATTLE)
			
			_clear_null_characters()
			
			return Battle.battle_list.find(character)
	
	## If no valid character is found
	push_error("No valid characters found for next index! ", old_index," ",Battle.battle_list)
	return -1

## Clearing the null values if they exist
func _clear_null_characters() -> void:
	for inst in Battle.battle_list:
		if !inst:
			Debug.message(["Clearing null characters..."],Debug.msg_category.BATTLE)
			Battle.battle_list.erase(inst)

func _load_next_character() -> void:
	
	## Set new character as next in queue, and incrementing the index
	var old_alignment = Battle.active_character_alignment
	var new_index = _find_next_valid_character(Battle.active_character_index)
	
	## Updating active index and character
	Battle.active_character_index = new_index
	Battle.active_character = Battle.battle_list[new_index]
	Battle.active_character_alignment = Battle.active_character.alignment

	## If we are now on the other team's turn sequence, let em know
	if old_alignment != Battle.active_character_alignment:
		Events.battle_team_start.emit(Battle.active_character_alignment)

func _next_turn() -> void:
	
	if _is_battle_over():
		return #Run some other code here later for post-game screen
	
	_load_next_character()
	
	Debug.message(["Starting turn for ",Battle.active_character.name],Debug.msg_category.BATTLE)
	
	Battle.camera_update()
	Battle.update_positions()
	
	Events.turn_start.emit() #Sends everyone a memo that there's a new turn

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
