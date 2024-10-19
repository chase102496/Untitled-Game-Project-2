extends Node

var active_character : Node3D = null
var battle_list : Array = []

#Glossary to spawn any character we need
const glossary : Dictionary = {
	"player" : preload("res://scenes/player.tscn"),
	"nym" : "",
	"some random enemy name" : ""
}

#Takes a list of nodes and their stats (or just an empty object with a stats dictionary telling us what to make it), an optional stat overwrite for variation via dictionary,
#and the old and new scenes they will be transitioning from and to.
func battle_initialize(list : Array, stat_merge : Array, scene_old, scene_new : String):
	var unit_instance
	battle_list = []
	
	#Instantiating all the battle characters
	for i in len(list):
		var unit_old : Object = list[i]
		var unit_glossary_code : String = unit_old.stats.glossary
		var unit_new : Object = Battle.glossary.get(unit_glossary_code) #plugging the VALUE of the glossary code into our global glossary to get a packed scene
		var stats_new : Dictionary = stat_merge[i]
		
		unit_instance = unit_new.instantiate()
		unit_instance.stats.merge(stats_new,true)
		#FIXME Replace this eventually with a signal and args
		
		#signal emit
		battle_list.append(unit_instance)
		
	scene_old.change_scene_to_file(scene_new)
	#broken \/
	#Events.on_battle_initialize.emit(battle_list)
