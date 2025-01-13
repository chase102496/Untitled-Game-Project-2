extends Node

## --- Functions --- ##

# Convert
## Grabs relevant info for displaying in a gui, and formats it into a Dictionary
## Can be a player, Dreamkin, Item, anything. It will tell us the type and forward a dict

func convert_info_universal_gui(entity):
	var result = Interface.evaluate_entity_type(entity)
	match result:
		Interface.entity_type.PLAYER, Interface.entity_type.SUMMONED_DREAMKIN, Interface.entity_type.PARTY_DREAMKIN:
			return convert_info_character_gui(entity)
		Interface.entity_type.PARTY_DREAMKIN:
			return convert_info_character_gui(entity)
		Interface.entity_type.INVENTORY_ITEM:
			return convert_info_item_gui(entity)
		Interface.entity_type.NOT_FOUND:
			pass

func convert_info_character_gui(character) -> Dictionary:
	
	var dict : Dictionary = {}
	
	var hp = Interface.get_root_health(character)
	var vs = Interface.get_root_vis(character)
	var abil = Interface.get_root_abilities(character)
	
	var abil_list = ""
	
	for a in abil:
		abil_list += str(Battle.type_color_dict(a.type),a.type.ICON,"[/color] ",a.title,
		"\n")
	
	match Interface.evaluate_entity_type(character):
		Interface.entity_type.PLAYER:
			dict.header = character.name
		Interface.entity_type.SUMMONED_DREAMKIN, Interface.entity_type.PARTY_DREAMKIN:
			dict.header = character.type.ICON + " " + character.name
		_:
			dict.header = character.name
	
	dict.sprite = null #TODO
	
	dict.description = str(
		Battle.type_color("HEALTH"),Battle.type.HEALTH.ICON,"[/color] ",hp.health,"/",hp.max_health,"  ",
		Battle.type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",vs.vis,"/",vs.max_vis,"\n",
		abil_list
	)

	return dict

func convert_info_item_gui(item : Object) -> Dictionary:
	
	var dict : Dictionary = {}
	
	dict.header = item.title
	
	dict.sprite = null #TODO
	
	dict.description = str(
		Glossary.text_style_color_html(Glossary.text_style.FLAVOR),item.flavor,"[/color] \n",
		"\n",
		item.description
	)
	
	return dict

## Used to transform from battle to entity or vice versa
func convert_entity_glossary(glossary_name : String, set_prefix : String):
	var result = ""
	if "world" in glossary_name:
		result = glossary_name.replace("world",set_prefix)
	elif "battle" in glossary_name:
		result = glossary_name.replace("battle",set_prefix)
	else:
		push_error("Unable to find transformation for ",glossary_name)
		
	return result

# Create

## Create custom parameters of a particle. Will modify the particle settings in the function
func create_fx_particle_custom(anchor : Node, type : String, one_shot : bool = false, amt : int = -1, spread : float = -1.0, speed : float = -1.0, direction : float = -1.0) -> Node:
	var inst = create_fx_particle(anchor,type,one_shot)
	if amt != -1:
		inst.amount = amt
	if spread != -1:
		inst.process_material.spread = spread
	if speed != -1:
		inst.process_material.initial_velocity_max = speed
		inst.process_material.initial_velocity_min = speed
	if direction != -1:
		inst.process_material.direction = direction
	
	return inst

## Quickly and easily create a particle. Will run however it was preconfigured
## Can use array as anchor to anchor to multiple nodes
func create_fx_particle(anchor, type : String, one_shot : bool = false):
	var scene = Glossary.particle.get(type)
	if scene:
		if anchor is Node:
			var inst = scene.instantiate()
			anchor.add_child(inst)
			inst.global_position = anchor.global_position
			
			if one_shot:
				inst.one_shot = true
			
			return inst
		elif anchor is Array:
			for each in anchor:
				if each is Node:
					var inst = scene.instantiate()
					each.add_child(inst)
					inst.global_position = each.global_position
					
					if one_shot:
						inst.one_shot = true
					
					return inst
				else:
					push_error("Cannot use type for anchor in array: ",each," ",anchor)
					return null
		else:
			push_error("Unknown particle anchor: ",anchor)
			return null
		
	else:
		push_error("No particle type found when creating fx particle: ",type)
		return null

## Creates an icon to be displayed in the status bar
## anchor in this case
## type is the name of the key in the status_icon glossary
## category is the status category. NORMAL, TETHER, or PASSIVE
func create_status_icon(anchor : Node, type : String) -> Control:
	var inst = Glossary.status_icon.get(type).instantiate()
	if inst:
		anchor.add_child(inst)
		inst.global_position = anchor.global_position
		return inst
	else:
		push_error("No status_icon type found when creating status_icon: ",type)
		return

func create_text_particle(anchor : Node, text : String = "TEST", type : String = "float_away", color : Color = Color.WHITE, delay : float = 0.0, size : int = 60):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	##Creation stuff
	var inst = Glossary.text.get(type).instantiate()
	if inst:
		var particle_label = inst.get_node("%particle_label")
		particle_label.text = text
		particle_label.label_settings.font_color = color
		particle_label.label_settings.font_size = size
		
		##Anchor stuff
		anchor.add_child(inst)
		#inst.global_position = anchor.global_position
		##Adjustments
		#inst.global_position.z += sign(Global.camera.global_position.z - inst.global_position.z) #Nudges us a bit toward the camera so we won't be behind the object
		
		return particle_label
	else:
		push_error("Text particle type ",type," not found.")
		return

func create_button_list(item_list : Array, parent : Node, callable_source : Node, pressed_signal : String, enter_hover_signal : String = "", exit_hover_signal : String = ""):
	
	var result : Array = []

	for item in item_list:
		var new_button = ui.empty_properties_button.instantiate()
		
		## Assign
		new_button.properties.item = item
		
		## Signal
		var packaged_callable = Callable(callable_source,pressed_signal)
		new_button.button_pressed_properties.connect(packaged_callable)
		
		if enter_hover_signal != "":
			var packed_callable_enter_hover = Callable(callable_source,enter_hover_signal)
			new_button.button_enter_hover_properties.connect(packed_callable_enter_hover)
		if exit_hover_signal != "":
			var packed_callable_exit_hover = Callable(callable_source,exit_hover_signal)
			new_button.button_exit_hover_properties.connect(packed_callable_exit_hover)
		
		## Finalize
		parent.add_child(new_button)
		result.append(new_button)
	
	return result

func create_options_list(properties : Dictionary, parent : Node, callable_source : Node, pressed_signal : String, battle_or_world : String):
	
	Glossary.free_children(parent)
	
	var item = properties.item
	var packed_callable = Callable(callable_source,pressed_signal)
	var new_button
	
	## Evaluate if pulling options or world
	var battle_or_world_options
	if battle_or_world == "battle":
		battle_or_world_options = item.options_battle
	elif battle_or_world == "world":
		battle_or_world_options = item.options_world
	else:
		push_error("Could not identify battle_or_world - ",battle_or_world)
	
	## Make button for each option
	for option in battle_or_world_options: #How do we handle modifying this?
		new_button = Glossary.ui.empty_properties_button.instantiate()
		
		## Assign
		new_button.properties.option_path = [option]
		new_button.properties.choices_path = []
		new_button.properties.item = item
		
		## Display
		new_button.text = option
		
		## Signal

		new_button.button_pressed_properties.connect(packed_callable)
		
		## Finalize
		parent.add_child(new_button)
	
	## Auto-calls if there's only one option
	if battle_or_world_options.size() == 1:
		packed_callable.call(new_button.properties)
	elif battle_or_world_options.size() == 0:
		push_error("Options Empty - ",properties)

# Misc

##SUPER USEFUL
##Tween any value based on importing it from a dictionary and tweening the current object's value to the one specificed in the dict
#For example dict : Dictionary = { "test.subvar" : 10 }
# Object.test.subvar = 1
# Tweens the Object.test.subvar from 1 to 10 in tween_duration seconds
func apply_changes_with_tween(target : Object, changes : Dictionary, tween_duration : float = 1.0) -> void:
	for key in changes:
		var value = changes[key]
		
		# Handle nested paths (e.g., "transform.origin")
		var path = key.split(".")
		var current = target
		for i in range(path.size() - 1):
			if path[i] not in current:
				print("Error: '%s' does not exist on '%s'" % [path[i], current.name])
				return
			current = current.get(path[i])
		
		# Set the final property or tween it
		var final_key = path[-1]
		
		if final_key in current:
			var current_value = current.get(final_key)
			
			# Tween if the value is tweenable
			if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
				var tween = create_tween()
				tween.tween_property(current, final_key, value, tween_duration)
			else:
				current.set(final_key, value)  # Direct set for non-tweenable values
		elif final_key.begins_with("shader_param:"):  # Handle shader parameters
			var param_name = final_key.replace("shader_param:", "")
			if current is Material:
				var current_value = current.get_shader_parameter(param_name)
				
				# Tween shader parameters if applicable
				if typeof(current_value) in [TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
					var tween = create_tween()
					tween.tween_method(current.set_shader_parameter, [param_name, current_value], [param_name, value], tween_duration)
				else:
					current.set_shader_parameter(param_name, value)  # Direct set for non-tweenable
			else:
				print("Error: '%s' is not a material, cannot set shader parameter '%s'" % [current.name, param_name])
		else:
			print("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])

##SUPER USEFUL
## WIP but working so far. Sets vars found on imported_data dict onto the target
## Also works for functions. Use the reference to the function in the key, and an array of arguments for the value
func deserialize_data(target : Object, imported_data : Dictionary) -> void:
	for key in imported_data:
		var value = imported_data[key]
		
		# Handle nested paths (e.g., "transform.origin")
		var path = key.split(".")
		var current = target
		for i in range(path.size() - 1):
			if path[i] not in current: #It's not a var
				if !current.has_method(path[i]): #It's not a method
					push_error("Error: '%s' does not exist on '%s'" % [path[i], current.name])
					return
			current = current.get(path[i])
		
		# Get the final property
		var final_key = path[-1]
		
		if final_key in current:
			##If it's a callable, the final key will be args in an array
			# The periods are the scope (so object_a.object_ab.current.final_key(value)
			if current.has_method(final_key):
				Callable(current,final_key).callv.call_deferred(value)
			else:
				current.set(final_key, value)
		#elif final_key.begins_with("shader_param:"):
			#var param_name = final_key.replace("shader_param:", "")
			#if current is Material:
				#current.set_shader_parameter(param_name, value)
			#else:
				#print("Error: '%s' is not a material, cannot set shader parameter '%s'" % [current.name, param_name])
		else:
			push_error("Error: Property '%s' does not exist on '%s'" % [final_key, current.name])

func text_style_color_html(type_dict : Dictionary):
	return str("[color=",type_dict.COLOR.to_html(),"]")

func get_unique_id():
	unique_id += 1
	return unique_id

func get_nested_value(dict: Dictionary, path: Array) -> Variant:
	var current = dict
	for key in path:
		if current.has(key):
			current = current[key]
		else:
			return null  # Path is invalid
	return current

func free_children(parent : Node):
	for child in parent.get_children():
			child.queue_free()

func evaluate_option_properties(properties : Dictionary, parent : Node, callable_source : Node, pressed_signal : String, battle_or_world : String, enter_hover_signal : String = "", exit_hover_signal : String = ""):
	var item = properties.item
	var option_path = properties.option_path
	var choices_path = properties.choices_path
	
	## Evaluate if pulling options or world
	var battle_or_world_options
	if battle_or_world == "battle":
		battle_or_world_options = item.options_battle
	elif battle_or_world == "world":
		battle_or_world_options = item.options_world
	else:
		push_error("Could not identify battle_or_world - ",battle_or_world)
	
	var current = get_nested_value(battle_or_world_options,option_path) #Grabs the contents of our current path the button is in
	
	##If we find nothing, just close the menu, we probably hit cancel
	if !current:
		return options_result.FINISHED
	
	##If we find that it's only a callable, call it
	elif current is Callable:
		current.callv(choices_path) #Call the end's script and insert our args we selected along the way
		return options_result.FINISHED
		
	
	##If we find choices within this selection
	elif "choices" in current:
		
		free_children(parent) #FREE THE CHILDREN, JIMMY!
		
		var returned_choices
		## Check if we need to pull live data, if so, call it
		# Pulls an string array of our choices
		if current["choices"] is Callable:
			returned_choices = current["choices"].call()
		else:
			returned_choices = current["choices"]
		
		var returned_choices_params
		if "choices_params" in current:
			## Checking if we need to pull live data, if so, call it
			# Pulls an array to eventually insert into the final callable
			if current["choices_params"] is Callable:
				returned_choices_params = current["choices_params"].call()
			## Else, it's an array. Just assign it
			else:
				returned_choices_params = current["choices_params"]
		
		var returned_choices_info
		if "choices_info" in current:
			## Checking if we need to pull live data, if so, call it
			# Pulls an array to eventually insert into the final callable
			if current["choices_info"] is Callable:
				returned_choices_info = current["choices_info"].call()
			## Else, it's an array. Just assign it
			else:
				returned_choices_info = current["choices_info"]
		
		## Run through all choices displayed, which is an array
		for i in returned_choices.size(): 
			var new_button = Glossary.ui.empty_properties_button.instantiate() #Create new button
			new_button.text = returned_choices[i]
			
			if returned_choices_info:
				new_button.properties.info = returned_choices_info[i] # Pass through the choice and its object for pulling info to display alongside the button on hover
			
			## Look ahead and assign that next step in our menu
			if "branch" in current:
				new_button.properties.option_path = option_path + ["branch",new_button.text] #Assign us to the branch that we specify from "choices"
			elif "next" in current:
				new_button.properties.option_path = option_path + ["next"] #Assign us to the next path, instead of a specific branch since there isn't one
			
			## Adds a parameter based on this button to our final script's arguments
			if returned_choices_params: #If we found a param list
				new_button.properties.choices_path = choices_path + [returned_choices_params[i]] #Add our specific choice
			else:
				new_button.properties.choices_path = choices_path #Keeps our existing choices from prev button
			
			new_button.properties.item = item #Make sure it still has the item as a reference
			
			## Add signal
			var packed_callable_pressed = Callable(callable_source,pressed_signal)
			new_button.button_pressed_properties.connect(packed_callable_pressed)
			if enter_hover_signal != "":
				var packed_callable_enter_hover = Callable(callable_source,enter_hover_signal)
				new_button.button_enter_hover_properties.connect(packed_callable_enter_hover)
			if exit_hover_signal != "":
				var packed_callable_exit_hover = Callable(callable_source,exit_hover_signal)
				new_button.button_exit_hover_properties.connect(packed_callable_exit_hover)
		
			## Finalize
			parent.add_child(new_button) #Add it as a child so it can be displayed properly
		
		return options_result.NEXT
			
	else:
		push_error("Invalid path for ", item, " - ", option_path, " - ",choices_path)
		return options_result.ERROR

## Used to find an entity in our glossary, with optional transform
func find_entity(glossary : String, set_prefix = null):
	var index = glossary
	if !entity_scene[index]:
		push_error("No entity found for query ",glossary)
		return
	elif set_prefix:
		index = convert_entity_glossary(glossary,set_prefix)
	return entity_scene[index]

## --- Dictionaries --- ##

# Packed Scenes

const particle : Dictionary = {
	### Status effects TBD
	#"status_fear" : preload("res://Scenes/particles/particle_fear.tscn"),
	#"status_burn" : preload("res://Scenes/particles/particle_burn.tscn"),
	#"status_freeze" : preload("res://Scenes/particles/particle_freeze.tscn"),
	#"status_disable" : preload("res://Scenes/particles/particle_disabled.tscn"),
	### World effects
	"heartsurge_node_lumia" : preload("res://Scenes/particles/particle_heartsurge_node_lumia.tscn"),
	"heartsurge_node_recall" : preload("res://Scenes/particles/particle_heartsurge_node_recall.tscn"),
	"heartsurge_node_clear" : preload("res://Scenes/particles/particle_heartsurge_node_clear.tscn")
	}

const status_icon : Dictionary = {
	"status_burn" : preload("res://Scenes/ui/status_icon/status_icon_burn.tscn"),
	"status_disable" : preload("res://Scenes/ui/status_icon/status_icon_disable.tscn"),
	"status_ethereal" : preload("res://Scenes/ui/status_icon/status_icon_ethereal.tscn"),
	"status_fear" : preload("res://Scenes/ui/status_icon/status_icon_fear.tscn"),
	"status_freeze" : preload("res://Scenes/ui/status_icon/status_icon_freeze.tscn"),
	"status_heartsurge" : preload("res://Scenes/ui/status_icon/status_icon_heartsurge.tscn"),
	"status_immunity" : preload("res://Scenes/ui/status_icon/status_icon_immunity.tscn"),
	"status_regrowth" : preload("res://Scenes/ui/status_icon/status_icon_regrowth.tscn"),
	"status_swarm" : preload("res://Scenes/ui/status_icon/status_icon_swarm.tscn"),
	"status_thorns" : preload("res://Scenes/ui/status_icon/status_icon_thorns.tscn"),
	"status_weakness" : preload("res://Scenes/ui/status_icon/status_icon_weakness.tscn"),
	}

const text : Dictionary = {
	"float_away" : preload("res://Scenes/particles/particle_text_damage.tscn")
	}

var entity_scene : Dictionary = {
	## DO NOT CHANGE TO PRELOAD
	"world_entity_dreamkin" : load("res://Scenes/characters/world/world_entity_dreamkin.tscn"),
	"battle_entity_dreamkin" : load("res://Scenes/characters/battle/battle_entity_dreamkin.tscn"), #TODO
	"battle_entity_enemy" : load("res://Scenes/characters/battle/battle_entity_enemy.tscn"),
	"battle_entity_player" : load("res://Scenes/characters/battle/battle_entity_player.tscn"),
	"world_entity_player" : load("res://Scenes/characters/world/world_entity_player.tscn"),
	}

## Contains all stuff needed to change visuals of an entity
const visual_set : Dictionary = {
	#"axolotl_red" : { TBD NEEDS REWORK
		#"SpriteFrames" : preload("res://Resources/SpriteFrames/dreamkin_red.tres"),
		#"AnimationLibrary" : preload("res://Resources/AnimationLibrary/default_basic.tres"),
		#"AnimationNodeStateMachine" : preload("res://Resources/AnimationNodeStateMachine/default_basic.tres"),
	#}
	}

const ui : Dictionary = {
	"empty_properties_button" : preload("res://Scenes/ui/empty_properties_button.tscn")
	}

# Classes

var ability_class : Dictionary = {
	"ability_tackle" : component_ability.ability_tackle,
	"ability_headbutt" : component_ability.ability_headbutt,
	"ability_solar_flare" : component_ability.ability_solar_flare,
	"ability_heartsurge" : component_ability.ability_heartsurge,
	"ability_switchstitch" : component_ability.ability_switchstitch,
	"ability_spook" : component_ability.ability_spook,
	"ability_frigid_core" : component_ability.ability_frigid_core,
	}

var status_class : Dictionary = {
	##Normal
	"status_fear" : component_ability.status_fear,
	"status_burn" : component_ability.status_burn,
	"status_freeze" : component_ability.status_freeze,
	##Tethers
	"status_heartsurge" : component_ability.status_heartsurge,
	##Passives
	"status_immunity" : component_ability.status_immunity, #Immune to specific aspect
	"status_weakness" : component_ability.status_weakness, #Weak to specific aspect
	"status_ethereal" : component_ability.status_ethereal, #Immune to all but one aspect
	"status_disable" : component_ability.status_disable, #Immune to everything and disabled
	"status_swarm" : component_ability.status_swarm, #Damage based on how many of it are on field
	"status_regrowth" : component_ability.status_regrowth, #Doesn't die unless its kind are all dead aswell
	"status_thorns" : component_ability.status_thorns, #Reflects damage on direct hit
	}

var item_class : Dictionary = {
	"item_nectar" : component_inventory.item_nectar,
	"item_dewdrop" : component_inventory.item_dewdrop
	}

# Encounters

## Used for referencing specific encounters
var encounter : Dictionary = {
	
	"gloamling_trio" : [
		
		{
			"glossary" : "battle_entity_enemy",
			"overrides" : {
				"my_component_health.max_health" : randi_range(4,12),
				"my_component_ability.add_ability" : [ability_class[ability_class.keys().pick_random()].new()]
				}
		},
	
		{
			"glossary" : "battle_entity_enemy",
			"overrides" : {
				"my_component_health.max_health" : randi_range(4,12),
				"my_component_ability.add_ability" : [ability_class[ability_class.keys().pick_random()].new()]
				}
		},
		
		{
			"glossary" : "battle_entity_enemy",
			"overrides" : {
				"my_component_health.max_health" : randi_range(4,12),
				"my_component_ability.add_ability" : [ability_class[ability_class.keys().pick_random()].new()]
				}
		},
		
		],
		
	"gloamling_duo" : [
		
		{
			"glossary" : "battle_entity_enemy",
			"overrides" : {
				"my_component_health.max_health" : randi_range(4,12),
				"my_component_ability.add_ability" : [component_ability.ability_solar_flare.new()]
				}
		},
	
		{
			"glossary" : "battle_entity_enemy",
			"overrides" : {
				"my_component_health.max_health" : randi_range(4,12),
				"my_component_ability.add_ability" : [component_ability.ability_spook.new()]
				}
		},
		
		],
		
	}

# Misc

## Used for unique IDs for each entity we spawn
# Unique to each playthrough and ascends to inf
var unique_id : int = randi_range(0,50)

var text_style : Dictionary = {
	"FLAVOR" :{
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
	}

var item_category : Dictionary = {
	"GEAR" : {
		"TITLE" : "Gear",
		"ICON" : "⌘",
		"COLOR" : Color("4acacf"),
		"TAB" : 0
	},
	"DREAMKIN" : {
		"TITLE" : "Dreamkin",
		"ICON" : "❖",
		"COLOR" : Color("4acacf"),
		"TAB" : 1
	},
	"ITEMS" : {
		"TITLE" : "Items",
		"ICON" : "⍟",
		"COLOR" : Color("4acacf"),
		"TAB" : 2
	},
	"KEYS" : {
		"TITLE" : "Keys",
		"ICON" : "🝰",
		"COLOR" : Color("4acacf"),
		"TAB" : 3
	}
	}

enum options_result {
	FINISHED,
	NEXT,
	ERROR
	}
