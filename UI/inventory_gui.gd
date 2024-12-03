extends Control

@export var my_component_party : component_party
@export var my_component_inventory : component_inventory
@onready var inventory_gui_tabs = %Tabs

@onready var inventory_gui_item_list = $PanelContainer/VBoxContainer/Panel/View/ScrollContainer/List
@onready var inventory_gui_item_list_info = $PanelContainer/VBoxContainer/Panel/View/Info
@onready var inventory_gui_item_list_info_label = $PanelContainer/VBoxContainer/Panel/View/Info/PanelContainer/VBoxContainer/Details/Label
@onready var inventory_gui_item_list_info_description_label = $PanelContainer/VBoxContainer/Panel/View/Info/PanelContainer/VBoxContainer/Details/Description

@onready var inventory_gui_options_barrier = $Options_Barrier
@onready var inventory_gui_options_panel = $PanelContainer2
@onready var inventory_gui_options_list = $PanelContainer2/List

@onready var state_chart : StateChart = %StateChart

func _ready() -> void:
	#Events.button_pressed_inventory_item_option.connect(_on_button_pressed_inventory_item_option)
	
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
			
	inventory_gui_options_panel.queue_sort()

func create_button_category_list(category_title : String):
	free_children(inventory_gui_item_list)
	
	var dict = my_component_inventory.get_items_from_category(category_title)
	dict.sort()

	for item in dict:
		var new_button = Glossary.ui.empty_properties_button.instantiate()
		
		## Assign
		new_button.properties.item = item
		
		## Display
		if item.quantity > 1:
			new_button.text = str(item.title,"  x",item.quantity)
		else:
			new_button.text = item.title
		
		## Signal
		new_button.button_pressed_properties.connect(_on_button_pressed_inventory_item)
		new_button.button_enter_hover_properties.connect(_on_button_enter_hover_inventory_item)
		new_button.button_exit_hover_properties.connect(_on_button_exit_hover_inventory_item)
		
		## Finalize
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

func options_close():
	inventory_gui_options_barrier.hide()
	inventory_gui_options_panel.hide()
	free_children(inventory_gui_options_list)
	refresh.call_deferred()

func options_create_list(properties : Dictionary):
	
	var item = properties.item
	
	free_children(inventory_gui_options_list)

	## Placing options window near the relevant item in the list
	var pos_button = Vector2.ZERO
	## Grab position of button we clicked
	for child in inventory_gui_item_list.get_children():
		if child.properties.item == item:
			pos_button = child.global_position + Vector2(0,child.get_size().y)
	## Adjusting position. Makes it easier to click and see. Displays directly below selected item
	inventory_gui_options_panel.global_position = pos_button
	
	## Make button for each option
	for option in item.options_world: #How do we handle modifying this?
		var new_button = Glossary.ui.empty_properties_button.instantiate()
		
		## Assign
		new_button.properties.option_path = [option]
		new_button.properties.choices_path = []
		new_button.properties.item = item
		
		## Display
		new_button.text = option
		
		## Signal
		new_button.button_pressed_properties.connect(_on_button_pressed_inventory_item_option)
		
		## Finalize
		inventory_gui_options_list.add_child(new_button)
		
	inventory_gui_options_panel.show()
	inventory_gui_options_barrier.show()

## --- Buttons ---

## Changing states tabs

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

func _on_button_pressed_inventory_item(properties : Dictionary):
	options_create_list(properties)

func _on_button_enter_hover_inventory_item(properties : Dictionary):
	
	var item = properties.item
	
	inventory_gui_item_list_info_label.text = item.title
	inventory_gui_item_list_info_description_label.text = str(
		Glossary.text_style_color_html(Glossary.text_style.FLAVOR),item.flavor,"[/color]",
		"\n",
		"\n",
		item.description
		)
	inventory_gui_item_list_info.show()
	
func _on_button_exit_hover_inventory_item(properties : Dictionary):
	inventory_gui_item_list_info.hide()

## Dreamkin buttons

func _on_button_pressed_dreamkin(properties : Dictionary):
	options_create_list(properties)
	
func _on_button_enter_hover_dreamkin(properties : Dictionary):
	var dreamkin = my_component_party.get_universal_data(properties.item)
	var abil_list = ""
	
	for i in dreamkin.my_abilities.size():
		abil_list += str(Battle.type_color_dict(dreamkin.my_abilities[i].type),dreamkin.my_abilities[i].type.ICON,"[/color] ",dreamkin.my_abilities[i].title,
		"\n")
	
	inventory_gui_item_list_info_label.text = str(dreamkin.type.ICON," ",dreamkin.name)
	
	inventory_gui_item_list_info_description_label.text = str(
		#Battle.type_color_dict(dreamkin.type),dreamkin.type.ICON,"[/color] ",dreamkin.name,"\n",
		Battle.type_color("HEALTH"),Battle.type.HEALTH.ICON,"[/color] ",dreamkin.health,"/",dreamkin.max_health,"  ",
		Battle.type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",dreamkin.vis,"/",dreamkin.max_vis,"\n",
		abil_list
	)

func _on_button_exit_hover_dreamkin(properties : Dictionary):
	pass

## Option buttons

func _on_button_pressed_inventory_item_option(properties : Dictionary):
	var item = properties.item
	var option_path = properties.option_path
	var choices_path = properties.choices_path
	
	var current = get_nested_value(item.options_world,option_path) #Grabs the contents of our current path the button is in
	
	##If we find nothing, just close the menu, we probably hit cancel
	if !current:
		options_close()
	
	##If we find that it's only a callable, call it
	elif current is Callable:
		current.callv(choices_path) #Call the end's script and insert our args we selected along the way
		options_close()
		
	
	##If we find choices within this selection
	elif "choices" in current:
		
		free_children(inventory_gui_options_list) #FREE THE CHILDREN, JIMMY!
		
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
		
		## Run through all choices displayed, which is an array
		for i in returned_choices.size(): 
			var new_button = Glossary.ui.empty_properties_button.instantiate() #Create new button
			new_button.text = returned_choices[i]
			
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
			new_button.button_pressed_properties.connect(_on_button_pressed_inventory_item_option)
			
			## Finalize
			inventory_gui_options_list.add_child(new_button) #Add it as a child so it can be displayed properly
			
	else:
		push_error("Invalid path for ", item, " - ", option_path, " - ",choices_path)

## ---      STATES      ---

## Enabled

func _on_state_entered_inventory_gui_enabled():
	show()

func _on_state_physics_processing_inventory_gui_enabled(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if inventory_gui_options_barrier.visible:
			options_close()
		else:
			state_chart.send_event("on_gui_toggle") #Disable the inventory
			owner.state_chart.send_event("on_disabled_toggle") #Enable the player

## Disabled

func _on_state_entered_inventory_gui_disabled():
	hide()
	inventory_gui_options_barrier.hide() #Hide options blocker if it was open
	inventory_gui_options_panel.hide() #Hide options if it was open
	inventory_gui_tabs.current_tab = 0 #Reset tabs to first
	free_children(inventory_gui_item_list)
	free_children(inventory_gui_options_list)
	
func _on_state_exited_inventory_gui_disabled():
	pass

## Gear

func _on_state_entered_inventory_gui_gear():
	free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.GEAR.TITLE)
	
func _on_state_exited_inventory_gui_gear():
	pass

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	free_children(inventory_gui_item_list)
	for dreamkin in my_component_party.get_hybrid_data_all():
		
		## Setup
		var new_button = Glossary.ui.empty_properties_button.instantiate()
		new_button.text = str(dreamkin.type.ICON," ",dreamkin.name)
		new_button.properties.item = dreamkin
		
		## Signals
		new_button.button_pressed_properties.connect(_on_button_pressed_dreamkin)
		new_button.button_enter_hover_properties.connect(_on_button_enter_hover_dreamkin)
		new_button.button_exit_hover_properties.connect(_on_button_exit_hover_dreamkin)
		
		## Finalize
		inventory_gui_item_list.add_child(new_button)
		new_button.show()

func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func _on_state_entered_inventory_gui_items():
	free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.ITEMS.TITLE)
	
func _on_state_exited_inventory_gui_items():
	pass

## Keys

func _on_state_entered_inventory_gui_keys():
	free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.KEYS.TITLE)

func _on_state_exited_inventory_gui_keys():
	pass
