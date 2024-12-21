extends Node

var active_character : Node3D = null
var active_character_index : int = 0
var battle_list : Array = []
var battle_list_ready : bool = true

## Name of encounter -> Callable
var battle_encounter : Dictionary = {
	"gloam_trio" : "enemy_gloam enemy_gloam enemy_gloam"
}

# Input
# Enemy class
# Health component : health, max_health
# Vis component : vis, max_vis
# Ability component : 
#	my_abilities : [ ability_1.new(damage,etc), ability_2.new(damage,etc) ]
#	my_status : [ status_1.new(damage,etc), status_2.new(damage,etc) ]
#	my_model : (Glossary reference to visual model that will contain sprites, animations, selector anchor, etc.)

## Name of location -> Encounter : Dict, Weight
var encounter_pool : Dictionary = {
	"veiled_forest" : {
		
	}
}

## Takes a list of nodes and their stats (or just an empty object with a stats dictionary telling us what to make it), an optional stat overwrite for variation via dictionary,
#and the old and new scenes they will be transitioning from and to.
func battle_initialize(entity_list, scene_new : String = "res://Levels/turn_arena.tscn"):
	
	##Save our current world info to load up
	PlayerData.save_data_scene()
	
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
		var unit_scene : PackedScene  = Glossary.find_entity(unit_name)
		var unit_instance = unit_scene.instantiate()
		
		#signal emit
		battle_list.append(unit_instance)
		
	SceneManager.transition_to(scene_new)

func battle_initialize_verbose(entity_list : Array, scene_new : String = "res://Levels/turn_arena.tscn"):
	
	##Save our current world info to load up later
	PlayerData.save_data_scene()
	
	battle_list.append(Glossary.entity["battle_entity_player"].instantiate())
	
	## Iterate through the list and instantiate them to ready for battle
	for entity in entity_list:
		battle_list.append(entity)
	
	SceneManager.transition_to(scene_new)

func battle_finalize():
	PlayerData.save_data_scene()
	SceneManager.transition_to_prev()


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

func type_color(type_string : String):
	return str("[color=",Battle.type.get(type_string).COLOR.to_html(),"]")

func type_color_dict(type_dict : Dictionary):
	return str("[color=",type_dict.COLOR.to_html(),"]")

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

func sort_screen(a,b): #Sorts based on screen X position (so left to right on screen)
	if Global.camera_object.unproject_position(a.global_position).x < Global.camera_object.unproject_position(b.global_position).x:
		return true
	else:
		return false

func mirror_section(start: int, end: int):
	# Validate input
	if start < 0 or end >= battle_list.size() or start >= end:
		push_error("Invalid input range")
	
	# Initialize pointers
	var left = start
	var right = end

	# Swap elements until pointers meet
	while left < right:
		# Swap elements at left and right
		var temp = battle_list[left]
		battle_list[left] = battle_list[right]
		battle_list[right] = temp

		# Move pointers closer
		left += 1
		right -= 1

func replace_member(new_member : Node,pos : int):
	battle_list[pos] = new_member
	update_positions()

func add_member(member : Node,pos : int):
	battle_list.insert(pos,member)
	update_positions()

func update_positions(): #Updates all units positions to reflect a change (like death or swap)
	var friends_offset := Vector3.ZERO
	var foes_offset := Vector3.ZERO
	for i in len(battle_list):
		
		var unit = battle_list[i]
		var tween = get_tree().create_tween()
		
		if !unit.is_queued_for_deletion(): #Check end of cycle to see if anyone gettin deleted, then move
			if unit.alignment == Battle.alignment.FOES:
				tween.tween_property(unit,"position",Vector3(foes_offset.x,unit.position.y,foes_offset.z),0.5)
				foes_offset -= unit.spacing
			else:
				tween.tween_property(unit,"position",Vector3(friends_offset.x,unit.position.y,friends_offset.z),0.5)
				friends_offset += unit.spacing

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
			result = opposing_team(caster)
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

func opposing_team(character : Node):
	if character.alignment == Battle.alignment.FRIENDS:
		return get_team(Battle.alignment.FOES)
	else:
		return get_team(Battle.alignment.FRIENDS)

func get_team(alignment : String):
	var team = []
	for i in len(battle_list):
		if battle_list[i].alignment == alignment:
			team.append(battle_list[i])
	return team

func check_ready():
	var result = true
	for i in len(battle_list):
		if !battle_list[i].my_component_state_controller_battle.character_ready:
			result = false
	return result

func camera_update():
	Global.camera.follow_target = active_character
