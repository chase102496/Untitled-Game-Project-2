extends Node

var active_character : Node3D = null
var battle_list : Array = []
var battle_list_ready : bool = true

func my_team(character):
	return get_team(character.stats.alignment)

func opposing_team(character):
	if character.stats.alignment == Global.alignment.FRIENDS:
		return get_team(Global.alignment.FOES)
	else:
		return get_team(Global.alignment.FRIENDS)

func get_team(alignment):
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
