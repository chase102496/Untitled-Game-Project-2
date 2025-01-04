extends Node

## Root filepath for persistent saves
var filepath : String = "user://save/" 
var filename_persistent : String = "resource_player_data_persistent.tres"

## For persistent data, like in a save file
var data_persistent_resource = resource_save_data.new()
# We access the same level as data session with:
# data_persistent_resource.data

## For single-session use
var data_session : Dictionary = {}

### --- Utility Functions --- ###

## Gets the specific save id of an object based on a global id
## This is somewhat redundant, but it creates it if we need to create which is handy
func get_save_id_global(obj : Object, all_data : Variant, global_id : String) -> String:
	if !all_data.has(global_id):
		all_data[global_id] = {}
	
	return global_id

## Gets the specific save location of an object with a save_id_scene
# This is used for saving scene-specific info, e.g. Levers being flipped, chests being opened, etc.
# Requires the object, and the dict or object we are looking for it
func get_save_id_scene(obj : Object, all_data : Variant) -> String:
	
	if !obj.has_meta("save_id_scene"):
		push_error("Saveable object did not have a save_id_scene. Make sure it is in the save_id_scene group :", obj.name, " ", obj)
	
	var scene_id = obj.get_meta("save_id_scene")

	## Might need to create new save spot for it
	if !all_data.has(scene_id):
		all_data[scene_id] = {}
	
	return scene_id

### --- Global Callables --- ###

##For single session use. Works as long as the session is alive.

func save_data_session():
	Debug.message("+ Saved session data",Debug.msg_category.SAVE)
	get_tree().call_group("save_data_session","on_save",SaveManager.data_session)

func load_data_session():
	if !Global.is_dictionary_completely_empty(data_session):
		get_tree().call_group("load_data_session","on_load",SaveManager.data_session) #Run custom function within each unit
		
		#Run generic save function for all units from SaveManager
		Debug.message("+ Loaded session data",Debug.msg_category.SAVE)
	else:
		Debug.message("+ No session data found to load, initializing...",Debug.msg_category.SAVE)

## For persistent data, like in a save file. Persists across sessions.

func save_data_persistent() -> void:
	Debug.message("+ Saved persistent data",Debug.msg_category.SAVE)
	get_tree().call_group("save_data_persistent","on_save",SaveManager.data_persistent_resource.data)
	
	ResourceSaver.save(data_persistent_resource, filepath + filename_persistent)

func load_data_persistent() -> void:
	if ResourceLoader.exists(filepath + filename_persistent):
		data_persistent_resource = ResourceLoader.load(filepath + filename_persistent).duplicate(true)
		get_tree().call_group("load_data_persistent","on_load",SaveManager.data_persistent_resource.data)
		Debug.message("+ Loaded persistent data",Debug.msg_category.SAVE)
	else:
		Debug.message("++ Making new persistent save file",Debug.msg_category.SAVE)

## TBD
func reset_data_persistent() -> void:
	pass
