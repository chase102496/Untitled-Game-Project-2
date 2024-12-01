extends Control

@export var my_component_inventory : component_inventory
@onready var inventory_gui_tabs = %Tabs

@onready var inventory_gui_item_list = $PanelContainer/VBoxContainer/Panel/View/ScrollContainer/List
@onready var inventory_gui_item_list_info = $PanelContainer/VBoxContainer/Panel/View/Info
@onready var inventory_gui_item_list_info_label = $PanelContainer/VBoxContainer/Panel/View/Info/PanelContainer/VBoxContainer/Details/Label
@onready var inventory_gui_item_list_info_description_label = $PanelContainer/VBoxContainer/Panel/View/Info/PanelContainer/VBoxContainer/Details/Description

@onready var inventory_gui_options = $Options
@onready var inventory_gui_options_panel = $Options/PanelContainer2
@onready var inventory_gui_options_list = $Options/PanelContainer2/List

@onready var ui_button_inventory_item : PackedScene = preload("res://UI/empty_item_button.tscn")
@onready var ui_button_inventory_item_option : PackedScene = preload("res://UI/empty_option_button.tscn")

@onready var state_chart : StateChart = %StateChart

func _ready() -> void:
	##Buttons
	Events.button_pressed_inventory_item.connect(_on_button_pressed_inventory_item)
	Events.mouse_entered_inventory_item.connect(_on_mouse_entered_inventory_item)
	Events.mouse_exited_inventory_item.connect(_on_mouse_exited_inventory_item)
	
	Events.button_pressed_inventory_item_option.connect(_on_button_pressed_inventory_item_option)
	
	inventory_gui_tabs.tab_selected.connect(_on_inventory_gui_tab_selected)
	
	%StateChart/Inventory_GUI/Disabled.state_entered.connect(_on_state_entered_inventory_gui_disabled)
	%StateChart/Inventory_GUI/Enabled.state_entered.connect(_on_state_entered_inventory_gui_enabled)
	%StateChart/Inventory_GUI/Enabled.state_physics_processing.connect(_on_state_physics_processing_inventory_gui_enabled)
	%StateChart/Inventory_GUI/Enabled/Gear.state_entered.connect(_on_state_entered_inventory_gui_gear)
	%StateChart/Inventory_GUI/Enabled/Dreamkin.state_entered.connect(_on_state_entered_inventory_gui_dreamkin)
	%StateChart/Inventory_GUI/Enabled/Items.state_entered.connect(_on_state_entered_inventory_gui_items)
	%StateChart/Inventory_GUI/Enabled/Keys.state_entered.connect(_on_state_entered_inventory_gui_keys)
	
	%StateChart/Inventory_GUI/Disabled.state_exited.connect(_on_state_exited_inventory_gui_disabled)
	%StateChart/Inventory_GUI/Enabled/Gear.state_exited.connect(_on_state_exited_inventory_gui_gear)
	%StateChart/Inventory_GUI/Enabled/Dreamkin.state_exited.connect(_on_state_exited_inventory_gui_dreamkin)
	%StateChart/Inventory_GUI/Enabled/Items.state_exited.connect(_on_state_exited_inventory_gui_items)
	%StateChart/Inventory_GUI/Enabled/Keys.state_exited.connect(_on_state_exited_inventory_gui_keys)

## --- Utility Functions ---

func convert_tab_to_glossary(tab : int):
	for key in Glossary.item_category:
		if Glossary.item_category[key].TAB == tab:
			return key

func free_children(parent : Node):
	for child in parent.get_children():
			child.queue_free()

func create_button_category_list(category : Dictionary):
	free_children(inventory_gui_item_list)
	for item in my_component_inventory.get_items_from_category(category):
		var new_button = ui_button_inventory_item.instantiate()
		new_button.item = item
		inventory_gui_item_list.add_child(new_button)
		new_button.show()

func refresh():
	var prev = inventory_gui_tabs.current_tab
	state_chart.send_event("on_gui_toggle")
	state_chart.send_event("on_gui_toggle")
	inventory_gui_tabs.current_tab = prev

func get_nested_value(dict: Dictionary, path: Array) -> Variant:
	var current = dict
	for key in path:
		if current.has(key):
			current = current[key]
		else:
			return null  # Path is invalid
	return current

## --- Buttons ---

## State functions

func _on_inventory_gui_tab_selected(tab : int):
	match convert_tab_to_glossary(tab):
		"GEAR":
			state_chart.send_event("on_gui_gear")
		"DREAMKIN":
			state_chart.send_event("on_gui_dreamkin")
		"ITEMS":
			state_chart.send_event("on_gui_items")
		"KEYS":
			state_chart.send_event("on_gui_keys")

## Item buttons

func _on_button_pressed_inventory_item(item : Object):
	
	free_children(inventory_gui_options_list)
	
	## Placing options window near the relevant item in the list
	var pos_button = Vector2.ZERO
	## Grab position of button we clicked
	for child in inventory_gui_item_list.get_children():
		if child.item == item:
			pos_button = child.global_position
	## Adjusting position. Makes it easier to click and see. Displays directly below selected item
	inventory_gui_options_panel.global_position = pos_button + (Vector2(0,inventory_gui_options_panel.get_size().y)/2)
	
	## Make button for each option
	for option in item.options_world:
		var new_button = ui_button_inventory_item_option.instantiate()
		new_button.option_path = [option]
		new_button.choices_path = []
		new_button.text = option
		new_button.item = item
		inventory_gui_options_list.add_child(new_button)
	
	inventory_gui_options.show()

func _on_mouse_entered_inventory_item(item : Object):
	inventory_gui_item_list_info_label.text = item.title
	inventory_gui_item_list_info_description_label.text = str(
		Glossary.text_style_color_html(Glossary.text_style.FLAVOR),item.flavor,"[/color]",
		"\n",
		"\n",
		item.description
		)
	inventory_gui_item_list_info.show()
	
func _on_mouse_exited_inventory_item(item : Object):
	inventory_gui_item_list_info.hide()

## Option buttons

func _on_button_pressed_inventory_item_option(item : Object, option_path : Array, choices_path : Array):
	
	var current = get_nested_value(item.options_world,option_path) #Grabs the contents of our current path the button is in
	if current is Callable:
		current.callv(choices_path) #Call the end's script and insert our args we selected along the way
		inventory_gui_options.hide()
		free_children(inventory_gui_options_list)
		
	elif "choices" in current: #If we fund choices within this selection we just selected, and there's another nested dir
		
		free_children(inventory_gui_options_list) #FREE THE CHILDREN, JIMMY!
		
		## Checking if we need to pull live data, if so, call it
		var returned_choices
		if current["choices"] is Callable:
			returned_choices = current["choices"].call()
		## Else, it's an array. Just assign it
		else:
			returned_choices = current["choices"]
			
		## Run through all choices, which is an array
		for i in returned_choices.size(): 
			var new_button = ui_button_inventory_item_option.instantiate() #Create new button
			
			## Look ahead and assign that next step in our menu
			if "next" in current:
				new_button.option_path = option_path + ["next"]
			elif "end" in current:
				new_button.option_path = option_path + ["end"]
			
			new_button.choices_path = choices_path + [returned_choices[i]] #Add our specific choice
			
			## Dynamic display to show something besides raw data array, in-sync index with "choices"
			## e.g. current["choices_display"][3] represents current["choices"][3]
			if "choices_display" in current:
				if current["choices_display"] is Callable:
					new_button.text = current["choices_display"].call()[i]
				else:
					new_button.text = current["choices_display"][i]
			else:
				new_button.text = str(returned_choices[i])
			
			new_button.item = item #Make sure it still has the item as a reference
			inventory_gui_options_list.add_child(new_button) #Add it as a child so it can be displayed properly
			
	else:
		push_error("Invalid path for ", item, " - ", option_path, " - ",choices_path)

## ---      STATES      ---

## Enabled

func _on_state_entered_inventory_gui_enabled():
	show()

func _on_state_physics_processing_inventory_gui_enabled(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_gui_toggle") #Disable the inventory
		owner.state_chart.send_event("on_disabled_toggle") #Enable the player

## Disabled

func _on_state_entered_inventory_gui_disabled():
	hide()
	inventory_gui_options.hide() #Hide options if it was open
	inventory_gui_tabs.current_tab = 0 #Reset tabs to first
	
func _on_state_exited_inventory_gui_disabled():
	pass

## Gear

func _on_state_entered_inventory_gui_gear():
	
	create_button_category_list(Glossary.item_category.GEAR)
	
func _on_state_exited_inventory_gui_gear():
	
	free_children(inventory_gui_item_list)

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	pass

func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func _on_state_entered_inventory_gui_items():
	
	create_button_category_list(Glossary.item_category.ITEMS)
	
func _on_state_exited_inventory_gui_items():

	free_children(inventory_gui_item_list)

## Keys

func _on_state_entered_inventory_gui_keys():
	
	create_button_category_list(Glossary.item_category.KEYS)

func _on_state_exited_inventory_gui_keys():

	free_children(inventory_gui_item_list)
	
