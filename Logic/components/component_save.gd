class_name component_save
extends Node

enum save_type {
	## Looks for it based on where we are in the scene. Useful for objects that only exist in one specific scene
	SCENE,
	## Looks across the entire savefile. Requires a manually-entered unique ID
	GLOBAL
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

func on_save(all_data : Variant) -> void:
	
	@warning_ignore("unused_variable")
	var data : Dictionary
	
	match my_save_type:
		save_type.SCENE:
			data = SaveManager.get_save_location_scene(self,all_data)
		save_type.GLOBAL:
			data = SaveManager.get_save_location_global(self,all_data,save_global_id)
	
	# Packs up all the variables and their paths in save_parent using save_list as ref to which to search for
	# Then packs them up and returns them as a dictionary
	data = Global.serialize_data(save_parent,save_list)
	
	#print($"../component_impulse_controller_switch".state_chart._state.initial_state)
	Global.peepee[name] = NodePath("Activated")
	#NodePath($"../component_impulse_controller_switch".state_chart.get_current_state())
	#print(NodePath($"../component_impulse_controller_switch".state_chart.get_current_state()))
	#print(Global.peepee)
	
	#print($"../component_impulse_controller_switch".state_chart._active_state)
	#$"../component_impulse_controller_switch".state_chart_initial_state = test_2

func on_load(all_data : Variant) -> void:
	#$"../component_impulse_controller_switch".state_chart.set_initial_state(Global.peepee[name])
	#print($"../component_impulse_controller_switch".state_chart.get_initial_state())
	
	$"../component_impulse_controller_switch".state_chart.set_load_state(Global.peepee[name],true)
	
	#$"../component_impulse_controller_switch".state_chart._state._active_state._state_enter()
	
	#$"../component_impulse_controller_switch".state_chart._state._state_enter.call_deferred()
	
