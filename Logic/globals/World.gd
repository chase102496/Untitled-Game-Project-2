extends Node

var last_player_position := Vector3(34,1.25,-29)

#Takes a list of nodes and their stats (or just an empty object with a stats dictionary telling us what to make it), an optional stat overwrite for variation via dictionary,
#and the old and new scenes they will be transitioning from and to.
func world_initialize(scene_new : String = "res://Levels/dream_garden.tscn"):
	
	var final_entity_list : Array = []
	
	if Global.player:
		final_entity_list.append(str("world_",Global.player.glossary))
	else: #If this is the first scene ever default to this
		final_entity_list.append("world_entity_player")
		
	if Global.player.my_component_party.party[0]: #If we have a primary dreamkin
		final_entity_list.append(str("world_",Global.player.my_component_party.party[0].glossary)) #Add our primary dreamkin's id
	
	if scene_new != str(get_tree().get_root().get_path()):
		get_tree().change_scene_to_file(scene_new)
	
	for i in final_entity_list.size():
		var unit_name : String = final_entity_list[i]
		var unit_scene : Object = Glossary.entity.get(unit_name) #plugging the VALUE of the glossary code into our global glossary to get a packed scene
		var final_instance = unit_scene.instantiate()
		get_tree().get_root().add_child(final_instance)
		final_instance.global_position = last_player_position
