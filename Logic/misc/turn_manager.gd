extends Node3D

@export var turn_pause_amount : float = 0.5
@export var spotlight : BattleSpotlight

var current_team_alignment : String
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
	Events.turn_repeat.connect(_on_turn_repeat)
	Events.turn_end.connect(_on_turn_end)
	Events.turn_start.connect(_on_turn_start)
	Events.battle_finished.connect(_on_battle_finished)
	
	#Initialize characters and battle list
	for i in Battle.battle_list.size():
		
		var instance = Battle.battle_list[i] #Our object to move into scene
		var parent = get_node(instance.alignment) #Side of the battlefield to spawn on
		parent.add_child(instance) #Adds it as a child to the position marker for our side of battlefield
		
		if i != 0:
			instance.state_chart.send_event.call_deferred("on_waiting")
		else:
			instance.state_chart.send_event.call_deferred("on_start")
			Battle.active_character = instance
			Battle.active_character_index = 0
	
	Battle.update_focus()
	
	current_team_alignment = Battle.active_character.alignment

### --- Signals --- ###

func _on_battle_entity_dying(entity : Node) -> void:
	
	Debug.message("Handling dying entity...",Debug.msg_category.BATTLE)
	
	if Battle.active_character == entity:
		Events.turn_end.emit()
		Battle.orphan_battle_spotlight()

func _on_battle_entity_death(entity : Node) -> void:
	
	Debug.message("Handling dead entity...",Debug.msg_category.BATTLE)
	
	 #trigger on death for all status stuff
	Battle.battle_list[Battle.battle_list.find(entity)] = null
	
	## Remove them from the world
	entity.queue_free()

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

### --- Turn Manipulation --- ###

## We essentially want to start the turn over with no updating of active_character
func _on_turn_repeat() -> void:
	Debug.message(["Repeating turn for ",Battle.active_character.name],Debug.msg_category.BATTLE)
	
	Battle.update_focus()
	
	Events.turn_start.emit()

## 
func _on_turn_start() -> void:
	pass

## Turn is over and we need to check if it's ok to start the next turn
func _on_turn_end() -> void:
	
	Debug.message("Ending turn...",Debug.msg_category.BATTLE)
	
	await get_tree().create_timer(0.2).timeout
	
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

## Turn is officially over and we now start the next turn
func _next_turn() -> void:
	
	if _is_battle_over():
		return #Run some other code here later for post-game screen
	
	_load_next_character()
	
	Debug.message(["Starting turn for ",Battle.active_character.name],Debug.msg_category.BATTLE)
	
	Battle.update_focus()
	
	if current_team_alignment != Battle.active_character.alignment:
		Events.battle_team_start.emit(Battle.active_character_alignment)
		current_team_alignment = Battle.active_character.alignment
		await get_tree().create_timer(turn_pause_amount).timeout
	
	Events.turn_start.emit() #Sends everyone a memo that there's a new turn

### --- Utility --- ###

## Clearing the null values if they exist
func _clear_null_characters() -> void:
	for inst in Battle.battle_list:
		if !inst:
			Debug.message(["Clearing null characters..."],Debug.msg_category.BATTLE)
			Battle.battle_list.erase(inst)

func _load_next_character() -> void:
	
	## Set new character as next in queue, and incrementing the index
	var new_index = _find_next_valid_character(Battle.active_character_index)
	
	## Updating active index and character
	Battle.active_character_index = new_index
	Battle.active_character = Battle.battle_list[new_index]
	Battle.active_character_alignment = Battle.active_character.alignment

### --- Getters --- ###

func _is_battle_over() -> bool:
	if Battle.get_team(Battle.alignment.FRIENDS).size() == 0:
		Events.battle_finished.emit("Lose")
		return true
	elif Battle.get_team(Battle.alignment.FOES).size() == 0:
		Events.battle_finished.emit("Win")
		return true
	else:
		return false

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
