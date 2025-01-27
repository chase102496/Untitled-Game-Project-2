class_name component_save
extends Node

enum save_type {
	## Looks for it based on where we are in the scene. Useful for objects that only exist in one specific scene
	SCENE,
	## Looks across the entire savefile. Requires a manually-entered unique ID
	GLOBAL,
	## No saving
	DISABLED
}

## Determines how to set and get our savefile
@export var my_save_type : save_type
## Only needed if save_type is GLOBAL
@export var save_global_id : String

## The parent node we are saving variables for. Leave blank to reference owner
@export var save_parent : Node

## The list of variables we are saving. Use node notation for nested variables e.g. "my_component_health.max_health"
@export var save_list : PackedStringArray

func _init() -> void:
	if my_save_type == save_type.SCENE:
		add_to_group("save_id_scene") #So we can get a save_id_scene when our scene is initialized or loaded

func _ready() -> void:
	if !save_parent:
		save_parent = owner

func find_save_id(all_data : Variant) -> String:
	
	var result
	match my_save_type:
		save_type.SCENE:
			result = SaveManager.get_save_id_scene(self,all_data)
		save_type.GLOBAL:
			result = SaveManager.get_save_id_global(self,all_data,save_global_id)
		save_type.DISABLED:
			result = null
			
	return result

func on_save(all_data : Variant) -> void:
	
	@warning_ignore("unused_variable")
	var key : String = find_save_id(all_data)
	
	if key != null:
		# Packs up all the variables and their paths in save_parent using save_list as ref to which to search for
		# Then packs them up and returns them as a dictionary
		all_data[key] = Global.serialize_data(save_parent,save_list)
		
		Debug.message(["component_save saved data: ",all_data[key]],Debug.msg_category.SAVE)

func on_load(all_data : Variant) -> void:
	
	@warning_ignore("unused_variable")
	var key : String = find_save_id(all_data)
	
	if key != null:
		
		Global.deserialize_data(save_parent,all_data[key])
		
		Debug.message(["component_save loaded data: ",all_data[key]],Debug.msg_category.SAVE)
	
