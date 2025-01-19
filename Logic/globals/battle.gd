extends Node

var active_character : Node3D = null
var active_character_index : int = 0
var active_character_alignment : String

var battle_list : Array = []
var battle_list_ready : bool = true

var battle_spotlight : BattleSpotlight
var battle_spotlight_target : Node3D
var battle_spotlight_tween : Tween

var death_queue : Array = []

## --- Dictionaries --- ##

const type : Dictionary = {
	"DESCRIPTION" :{
		"COLOR" : Color("5c5c5c")
	},
	"HEALTH" :{
		"ICON" : "♥",
		"COLOR" : Color("f4085b")
	},
	"VIS" :{
		"ICON" : "◆",
		"COLOR" : Color("078ef5")
	},
	"EMPTY" : {
		"TITLE" : "",
		"ICON" : ""
	},
	"TETHER" : {
		"TITLE" : "Tether",
		"ICON" : "※",
		"COLOR" : Color("4acacf")
	},
	"BALANCE" : {
		"TITLE" : "Balance",
		"ICON" : "●",
		"COLOR" : Color("ffffff")
	},
	"VOID" : {
		"TITLE" : "Void",
		"ICON" : "✫",
		"COLOR" : Color("342d6bfd")
	},
	"CHAOS" : {
		"TITLE" : "Chaos",
		"ICON" : "✯",
		"COLOR" : Color("f2af5cfd")
	},
	"ORDER" : {
		"TITLE" : "Order",
		"ICON" : "⬡",
		"COLOR" : Color("6b1e1efd")
	},
	"FLOW" : {
		"TITLE" : "Flow",
		"ICON" : "≋",
		"COLOR" : Color("4f1e6bfd")
	},
}

const status_category : Dictionary = {
	"NORMAL" : "NORMAL",
	"TETHER" : "TETHER",
	"PASSIVE" : "PASSIVE"
}

const classification : Dictionary = {
	"PLAYER" : "PLAYER",
	"DREAMKIN" : "DREAMKIN",
	"ENEMY" : "ENEMY",
	"ITEM" : "ITEM"
}

const alignment : Dictionary = {
	"FRIENDS" : "FRIENDS",
	"FOES" : "FOES"
}

const status_behavior : Dictionary = { #When a status effect is applied to a target who already has it
	"STACK" : "STACK", #Add duration on top of the existing one, but doesn't send new info to target besides that
	"RESET" : "RESET", #Reset the duration to the new ability's duration, and sends new info to target like its partners for a tether
	"RESIST" : "RESIST" #Do nothing
}

const target_selector : Dictionary = { #Populates the selection with a modifier, like two targets or more
	"SINGLE" : {
		"DESCRIPTION" : "Targets only your selection"
		}, #One target
	"SINGLE_RIGHT" : { #One target, and the one to the right of them
		"DESCRIPTION" : "Targets your selection and its RIGHT neighbor"
		}, #One target
	"SINGLE_LEFT" : {
		"DESCRIPTION" : "Targets your selection and its LEFT neighbor"
		}, #One target
	"SINGLE_ADJACENT" : { #One target, and both adjacent targets
		"DESCRIPTION" : "Targets your selection and both LEFT and RIGHT neighbors"
		}, #One target
	"TEAM" : { #Target one side of the field
		"DESCRIPTION" : "Targets a team"
		}, #One target
	"ALL" : { #Whole field
		"DESCRIPTION" : "Targets everyone"
		}, #One target
	"NONE" : { #Doesn't need a target to use move
		"DESCRIPTION" : ""
		}, #One target
}

const target_type : Dictionary = { #Populates our available targets when using an ability
	"SELF" : "SELF",
	"OTHERS" : "OTHERS", #Everyone besides me
	"ALLIES" : "ALLIES", #My team
	"OPPONENTS" : "OPPONENTS", #Enemy team
	"OTHER_ALLIES" : "OTHER_ALLIES", #My team minus me
	"EVERYONE" : "EVERYONE"
}

const mitigation_type : Dictionary = { #Informs our system if something mitigated an ability and what it did, or if it didn't do anything at all
	"PASS" : "PASS",
	"IMMUNE" : "IMMUNE",
	"WEAK" : "WEAK"
}

## --- Functions --- ##

# Battle

## Takes a list of nodes and their stats (or just an empty object with a stats dictionary telling us what to make it), an optional stat overwrite for variation via dictionary,
#and the old and new scenes they will be transitioning from and to.
func battle_initialize(entity_list, scene_new : String = "res://Levels/turn_arena.tscn") -> void:
	
	_battle_reset()
	
	##Save our current world info to load up
	SaveManager.save_data_session()
	
	var final_entity_list : Array = []
	
	final_entity_list.append("battle_entity_player")
	
	#if Global.player.my_component_party.get_party(): #If we have some party members
	#	final_entity_list.append(Glossary.convert_entity_glossary(Global.player.my_component_party.my_party[0].glossary,"battle")) #Add our primary dreamkin's id
	
	if entity_list is String: #For conversion from dialogic method
		var split_list = entity_list.split(" ")
		for i in split_list.size():
			var fixed_str = str("battle_entity_",split_list[i])
			final_entity_list.append(fixed_str)
	elif entity_list is Array: #If it's a list
		if entity_list[0] is String:
			for i in entity_list.size():
				if entity_list[i] is String:
					final_entity_list.append(entity_list[i])
				else:
					push_error("ERROR: Entity was not string when subdivided: ",entity_list[i])
		## If we're using a verbose list of nodes with specific parameters
		elif entity_list[0] is Node:
			pass

	battle_list = []
	#Instantiating all the battle characters
	for i in len(final_entity_list):
		var unit_name : String = final_entity_list[i]
		var unit_scene : PackedScene  = Glossary.get_entity(unit_name)
		var unit_instance = unit_scene.instantiate()
		
		#signal emit
		battle_list.append(unit_instance)
		
	SceneManager.transition_to(scene_new)

##
func battle_initialize_verbose(entity_list : Array, scene_new : String = "res://Levels/turn_arena.tscn") -> void:
	
	_battle_reset()
	
	##Save our current world info to load up later
	SaveManager.save_data_session()
	
	battle_list.append(Entity.new().create("battle_entity_player"))
	
	## Iterate through the list and instantiate them to ready for battle
	for unit in entity_list:
		## Key = name of entity we spawn
		## Val = dictionary to merge with theirs (health, run functions, etc)
		battle_list.append(Entity.new().create(unit["glossary"],unit["overrides"]))
	
	SceneManager.transition_to(scene_new)

##
func battle_finalize() -> void:
	_battle_reset.call_deferred()
	SaveManager.save_data_session()
	SceneManager.transition_to_prev()

##
func _battle_reset() -> void:
	Battle.battle_list.clear()

### --- Utility Commands --- ###

## Updates position, camera, and spotlight in one wrapper
func update_focus():
	var tween_list = update_positions()
	
	for tween in tween_list:
		if tween.is_running():
			await tween.finished
	
	update_camera()
	update_spotlight()
	
	if battle_spotlight_tween.is_running():
		await battle_spotlight_tween.finished

## Updates all units positions to reflect a change (like death or swap)
## Returns a list of all the tweens for each unit currently moving to its next position
func update_positions() -> Array[Tween]:
	var friends_offset := Vector3.ZERO
	var foes_offset := Vector3.ZERO
	var tween_list : Array[Tween] = []
	for unit in battle_list:
		
		if unit and !unit.is_queued_for_deletion(): #Check end of cycle to see if anyone gettin deleted, then move
			
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_BACK)
			
			if unit.alignment == Battle.alignment.FOES:
				foes_offset -= unit.spacing
				tween.tween_property(unit,"position",Vector3(foes_offset.x,unit.collider.shape.height/2,foes_offset.z),0.3)
				foes_offset -= unit.spacing
			else:
				friends_offset += unit.spacing
				tween.tween_property(unit,"position",Vector3(friends_offset.x,unit.collider.shape.height/2,friends_offset.z),0.3)
				friends_offset += unit.spacing
			
			tween_list.append(tween)
	
	return tween_list

## Will completely swap orders of a section of units (e.g. [1,2,3] -> [3,2,1]
func swap_position_list(start: int, end: int, update_active_character : bool = false):
	
	var active_character_old_index = battle_list.find(active_character)
	
	## Fix out of bounds inputs
	var result_start : int = clamp(start,0,battle_list.size() - 1)
	var result_end : int = clamp(end,0,battle_list.size() - 1)
	## For comparison later
	var swap_list = battle_list.slice(result_start,result_end+1)
	
	# Initialize pointers
	var left = result_start
	var right = result_end

	# Swap elements until pointers meet
	while left < right:
		# Swap elements at left and right
		var temp = battle_list[left]
		battle_list[left] = battle_list[right]
		battle_list[right] = temp

		# Move pointers closer
		left += 1
		right -= 1
	
	### If active char was in our swap list, and we wanna update the active character to the old position of them
	if update_active_character:
		if active_character in swap_list:
			Battle.active_character = Battle.battle_list[active_character_old_index]
			Events.turn_start.emit()
		else:
			push_warning("No active character inside mirror section to reflect active_character update")
	
	update_focus()

##
func replace_member(new_member : Node,pos : int):
	battle_list[pos] = new_member

##
func add_member(member : Node,pos : int):
	battle_list.insert(pos,member)
	update_focus()

#### --- Turn-related --- ###

## Trigger the next death in death queue
func run_death_queue() -> void:
	for inst in death_queue:
		inst.state_chart.send_event("on_death")
		death_queue.erase(inst)

## Add someone to die soon
func add_death_queue(char : Node) -> void:
	if char in death_queue:
		Debug.message("Character already exists in death_queue. Cannot add",Debug.msg_category.BATTLE)
	else:
		death_queue.append(char)

func check_ready() -> bool:
	for char in battle_list:
		if char and !char.my_component_state_controller_battle.is_character_ready:
			return false
	return true

### --- Grabbers --- ###

func get_relative_character(index_direction : int):
	var result_index = Global.get_relative_index(battle_list,battle_list.find(active_character),index_direction)
	return battle_list[result_index]

func get_target_selector_list(target : Node, selector : Dictionary, target_type_list : Array): #Returns the other targets in addition to the main selected one, based off the list provided
	var result : Array = []
	match selector:
		Battle.target_selector.SINGLE:
			result = [target]
		Battle.target_selector.SINGLE_RIGHT:
			result.append(target)
			var target_secondary_index = target_type_list.find(target) + 1
			if target_secondary_index < len(target_type_list):
				result.append(target_type_list[target_secondary_index])
		Battle.target_selector.SINGLE_LEFT:
			result.append(target)
			var target_secondary_index = target_type_list.find(target) - 1
			if target_secondary_index > -1:
				result.append(target_type_list[target_secondary_index])
		Battle.target_selector.SINGLE_ADJACENT:
			result.append(target)
			var target_secondary_index = target_type_list.find(target) + 1
			var target_tertiary_index = target_type_list.find(target) - 1
			if target_secondary_index < len(target_type_list):
				result.append(target_type_list[target_secondary_index])
			if target_tertiary_index > -1:
				result.append(target_type_list[target_tertiary_index])
		Battle.target_selector.TEAM:
			for i in len(target_type_list):
				if target_type_list[i].alignment == target.alignment:
					result.append(target_type_list[i])
		Battle.target_selector.ALL:
			result = target_type_list
		Battle.target_selector.NONE:
			pass
		_:
			push_error("ERROR, INVALID CHARACTER, SELECTOR, OR TYPE: ",target,selector,type)
		
	return result

func get_target_type_list(caster : Node,type : String,sorted : bool = false): #returns list of characters based on type we want, optionally sorted from left to right on screen for selection purposes
	var result : Array = []
	var ref_battle_list = battle_list.duplicate()
	match type:
		Battle.target_type.SELF:
			result = [caster]
		Battle.target_type.OTHERS:
			ref_battle_list.pop_at(ref_battle_list.find(caster))
			result = ref_battle_list
		Battle.target_type.ALLIES:
			result = my_team(caster)
		Battle.target_type.OPPONENTS:
			result = get_opposite_team(caster)
		Battle.target_type.OTHER_ALLIES:
			var team = my_team(caster)
			team.pop_at(team.find(caster))
			result = team
		Battle.target_type.EVERYONE:
			result = ref_battle_list
		_:
			push_error("ERROR, INVALID CASTER OR TYPE: ",caster,type)
			
	if sorted:
		result.sort_custom(sort_screen)
		
	return result

func my_team(character : Node):
	return get_team(character.alignment)

func get_opposite_team(character : Node):
	if character.alignment == Battle.alignment.FRIENDS:
		return get_team(Battle.alignment.FOES)
	else:
		return get_team(Battle.alignment.FRIENDS)

## Returns the given alignment, either FRIENDS or FOES
## If an entity is dead (I.E. null value in the list) we ignore it and only pull non-dead entities
func get_team(alignment : String):
	var team : Array = []
	for entity in battle_list:
		if entity and entity.alignment == alignment:
			team.append(entity)
	return team

func get_type_color(type_string : String):
	return str("[color=",Battle.type.get(type_string).COLOR.to_html(),"]")

func get_type_color_dict(type_dict : Dictionary):
	return str("[color=",type_dict.COLOR.to_html(),"]")

func sort_screen(a,b): #Sorts based on screen X position (so left to right on screen)
	if Global.camera_object.unproject_position(a.global_position).x < Global.camera_object.unproject_position(b.global_position).x:
		return true
	else:
		return false

func search_glossary_name(character_name : String, character_list : Array, first_result : bool = true): #Search glossary names of all characters specified and return matches
	var character_result_list : Array = []
	
	for i in len(character_list):
		if character_list[i].glossary == character_name: #find the name
			if first_result: #if first result is enabled
				return character_list[i] #return it
			else:
				character_result_list.append(character_list[i])
	
	if !first_result:
		return character_result_list
	else:
		return null

func search_classification(classification : String, alignment : String): #Returns a list of all the battle list units matching this classification
	var result : Array = []
	for i in get_team(alignment).size():
		if battle_list[i].classification == classification:
			result.append(battle_list[i])
	return result

### --- Battle Spotlight --- ###

func update_spotlight():
	set_battle_spotlight_target(active_character)

func update_camera() -> void:
	Global.camera.follow_target = active_character

func orphan_battle_spotlight() -> void:
	battle_spotlight.remote_transform.remote_path = ""
	battle_spotlight.hide()

func set_battle_spotlight_target(target : Node3D) -> void:
	
	if !battle_spotlight.visible:
		battle_spotlight.show()
	
	var tween_time = 0.3
	if target != battle_spotlight_target:
		battle_spotlight_target = target
		
		battle_spotlight_tween = create_tween()
		battle_spotlight_tween.set_ease(Tween.EASE_OUT)
		battle_spotlight_tween.set_trans(Tween.TRANS_BACK)
		battle_spotlight_tween.tween_property(battle_spotlight,"global_position",Vector3(target.global_position.x,battle_spotlight.global_position.y,target.global_position.z),tween_time)
		battle_spotlight.remote_transform.remote_path = get_path_to(target)


func set_battle_spotlight_brightness(brightness : float,time : float = 0) -> void:
	if battle_spotlight.light.light_energy != brightness:
		var tween = create_tween()
		tween.tween_property(battle_spotlight.light,"light_energy",brightness,time)

func reset_battle_spotlight_brightness(time : float = 0) -> void:
	var brightness = 12
	if battle_spotlight.light.light_energy != brightness:
		var tween = create_tween()
		tween.tween_property(battle_spotlight.light,"light_energy",brightness,time)
