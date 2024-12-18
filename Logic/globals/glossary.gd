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

func create_text_particle(anchor : Node, text : String = "TEST", type : String = "float_away", color : Color = Color.WHITE, delay : float = 0.0, size : int = 60):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	##Creation stuff
	var inst = Glossary.text.get(type).instantiate()
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
	if set_prefix:
		index = convert_entity_glossary(glossary,set_prefix)
	return entity[index]


## --- Dictionaries --- ##

# Scenes

const particle : Dictionary = {
	"fear" : preload("res://Art/particles/scenes/particle_fear.tscn"),
	"burn" : preload("res://Art/particles/scenes/particle_burn.tscn"),
	"freeze" : preload("res://Art/particles/scenes/particle_freeze.tscn"),
	"disabled" : preload("res://Art/particles/scenes/particle_disabled.tscn")
	}

const text : Dictionary = {
	"float_away" : preload("res://Art/particles/scenes/particle_text_damage.tscn")
	}

const entity : Dictionary = {
	
	# Players
	"battle_entity_player" : preload("res://Scenes/characters/battle_entity_player.tscn"),
	"world_entity_player" : preload("res://Scenes/characters/world_entity_player.tscn"),
	
	# Dreamkin
	"battle_entity_dreamkin_default" : preload("res://Scenes/characters/battle_entity_dreamkin_default.tscn"),
	"world_entity_dreamkin_default" : preload("res://Scenes/characters/world_entity_dreamkin_default.tscn"),
	#
	"battle_entity_dreamkin_sparx" : preload("res://Scenes/characters/battle_entity_dreamkin_sparx.tscn"),
	# Enemies
	"battle_entity_enemy_default" : preload("res://Scenes/characters/battle_entity_enemy_default.tscn"),
	"battle_entity_enemy_elderoot" : preload("res://Scenes/characters/battle_entity_enemy_elderoot.tscn"),
	"battle_entity_enemy_core_warden" : preload("res://Scenes/characters/battle_entity_enemy_duskling.tscn"),
	"battle_entity_enemy_shadebloom" : preload("res://Scenes/characters/battle_entity_enemy_shadebloom.tscn"),
	"battle_entity_enemy_shiverling" : preload("res://Scenes/characters/battle_entity_enemy_shiverling.tscn"),
	"battle_entity_enemy_cinderling" : preload("res://Scenes/characters/battle_entity_enemy_cinderling.tscn"),
	"battle_entity_enemy_gloam" : preload("res://Scenes/characters/battle_entity_enemy_gloam.tscn"),
	}

const sprite : Dictionary = {
	"placeholder" : preload("res://Art/sprites/scenes/placeholder.tscn")
	}

const ui : Dictionary = {
	"heartlink" : preload("res://UI/status_effect_heartlink.tscn"),
	"empty_properties_button" : preload("res://UI/empty_properties_button.tscn")
	}

# Classes

var ability_class : Dictionary = {
	"ability_tackle" : component_ability.ability_tackle,
	"ability_headbutt" : component_ability.ability_headbutt,
	"ability_solar_flare" : component_ability.ability_solar_flare,
	"ability_heartlink" : component_ability.ability_heartlink,
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
	"status_heartlink" : component_ability.status_heartlink,
	##Passives
	"status_immunity" : component_ability.status_immunity, #Immune to specific aspect
	"status_weakness" : component_ability.status_weakness, #Weak to specific aspect
	"status_ethereal" : component_ability.status_ethereal, #Immune to all but one aspect
	"status_disabled" : component_ability.status_disabled, #Immune to everything and disabled
	"status_swarm" : component_ability.status_swarm, #Damage based on how many of it are on field
	"status_regrowth" : component_ability.status_regrowth, #Doesn't die unless its kind are all dead aswell
	"status_thorns" : component_ability.status_thorns, #Reflects damage on direct hit
	}

var item_class : Dictionary = {
	"item_nectar" : component_inventory.item_nectar,
	"item_dewdrop" : component_inventory.item_dewdrop
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
