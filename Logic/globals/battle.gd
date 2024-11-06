extends Node

var active_character : Node3D = null
var battle_list : Array = []
var battle_list_ready : bool = true

const type : Dictionary = {
	"EMPTY" : {
		"TITLE" : "",
		"ICON" : ""
	},
	"NEUTRAL" : {
		"TITLE" : "Neutral",
		"ICON" : "●"
	},
	"VOID" : {
		"TITLE" : "Void",
		"ICON" : "✫"
	},
	"NOVA" : {
		"TITLE" : "Nova",
		"ICON" : "✯"
	},
	"TERA" : {
		"TITLE" : "Tera",
		"ICON" : "⬡"
	},
	"ETHEREAL" : {
		"TITLE" : "Ethereal",
		"ICON" : "≋"
	},
}

const status_type : Dictionary = {
	"NORMAL" : {
		"TITLE" : "Normal",
		"ICON" : ""
	},
	"TETHER" : {
		"TITLE" : "Tether",
		"ICON" : "⛓"
	}
}

const target_selector : Dictionary = { #Decides who to actually apply the move on
	"SINGLE" : "Single", #One target
	"SINGLE_RIGHT" : "Single Right", #One target, and the one to the right of them
	"SINGLE_LEFT" : "Single Left",
	"SINGLE_ADJACENT" : "Single Adjacent", #One target, and both adjacent targets
	"TEAM" : "Team", #Target one side of the field
	"ALL" : "All", #Whole field
	"NONE" : "None" #Doesn't need a target to use move
}

const target_type : Dictionary = { #Populates our selection list
	"SELF" : "Self",
	"OTHERS" : "Others", #Everyone besides me
	"ALLIES" : "Allies", #My team
	"OPPONENTS" : "Opponents", #Enemy team
	"OTHER_ALLIES" : "Other Allies", #My team minus me
	"EVERYONE" : "Everyone"
}

const alignment : Dictionary = {
	"FRIENDS" : "Friends",
	"FOES" : "Foes"
	}

#func team_adjacent(character : Node,direction : int):
	#var team = my_team(character)
	##something +1 blah blah

func sort_screen(a,b): #Sorts based on screen X position (so left to right on screen)
	if Global.camera_object.unproject_position(a.global_position).x < Global.camera_object.unproject_position(b.global_position).x:
		return true
	else:
		return false

func get_target_selector_list(target : Node, selector : String, target_type_list : Array): #Returns the other targets in addition to the main selected one, based off the list provided
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
			if target_secondary_index > -1:
				result.append(target_type_list[target_tertiary_index])
		Battle.target_selector.TEAM:
			pass
		Battle.target_selector.ALL:
			pass
		Battle.target_selector.NONE:
			pass
		_:
			push_error("ERROR, INVALID CHARACTER, SELECTOR, OR TYPE: ",target,selector,type)
		
	return result

func get_target_type_list(character : Node,type : String,sorted : bool = false): #returns list of characters based on type we want, optionally sorted from left to right on screen for selection purposes
	var result : Array = []
	var ref_battle_list = battle_list.duplicate()
	match type:
		Battle.target_type.SELF:
			result.append(character)
		Battle.target_type.OTHERS:
			ref_battle_list.pop_at(ref_battle_list.find(character))
			result = ref_battle_list
		Battle.target_type.ALLIES:
			result = my_team(character)
		Battle.target_type.OPPONENTS:
			result = opposing_team(character)
		Battle.target_type.OTHER_ALLIES:
			var team = my_team(character)
			team.pop_at(team.find(character))
			result = team
		Battle.target_type.EVERYONE:
			result = ref_battle_list
		_:
			push_error("ERROR, INVALID CHARACTER OR TYPE: ",character,type)
			
	if sorted:
		result.sort_custom(sort_screen)
		
	return result

func my_team(character : Node):
	return get_team(character.stats.alignment)

func opposing_team(character : Node):
	if character.stats.alignment == Battle.alignment.FRIENDS:
		return get_team(Battle.alignment.FOES)
	else:
		return get_team(Battle.alignment.FRIENDS)

func get_team(alignment : String):
	var team = []
	for i in len(battle_list):
		if battle_list[i].stats.alignment == alignment:
			team.append(battle_list[i])
	return team

func check_ready():
	var result = true
	for i in len(battle_list):
		if !battle_list[i].my_component_state_controller_battle.character_ready:
			result = false
	return result

#Takes a list of nodes and their stats (or just an empty object with a stats dictionary telling us what to make it), an optional stat overwrite for variation via dictionary,
#and the old and new scenes they will be transitioning from and to.
func battle_initialize(unit_list : Array, stat_list : Array, scene_old, scene_new : String):
	var unit_instance
	battle_list = []
	
	#Instantiating all the battle characters
	for i in len(unit_list):
		var unit_name : String = unit_list[i]
		var unit_scene : Object = Glossary.entity.get(unit_name) #plugging the VALUE of the glossary code into our global glossary to get a packed scene
		var unit_stats : Dictionary = stat_list[i]
		
		unit_instance = unit_scene.instantiate()
		unit_instance.stats.merge(unit_stats,true)
		#FIXME Replace this eventually with a signal and args
		
		#signal emit
		battle_list.append(unit_instance)
		
	scene_old.change_scene_to_file(scene_new)
	#broken \/
	#Events.on_battle_initialize.emit(battle_list)
