extends Control

@export var my_component_party : component_party
@export var my_component_inventory : component_inventory

### --- HUD --- ###

@onready var hud_gui = %HUD

### --- Inventory --- ###

@onready var inventory_gui = %Inventory
@onready var inventory_gui_tabs = %Tabs

## Content
@onready var inventory_gui_item_grid = %ContentGrid

## Info
@onready var inventory_gui_item_grid_info = %Inventory/Info
@onready var inventory_gui_item_grid_info_label = %Inventory/Info/VBoxContainer/Details/Label
@onready var inventory_gui_item_grid_info_description_label = %Inventory/Info/VBoxContainer/Details/Description

## Options
@onready var inventory_gui_options_barrier = %Inventory/Options
@onready var inventory_gui_options_panel = %Inventory/Options/Submenu
@onready var inventory_gui_options_list = %Inventory/Options/Submenu/List

@onready var state_chart : StateChart = %StateChart

func _ready() -> void:
	#Events.button_pressed_inventory_item_option.connect(_on_button_pressed_inventory_item_option)
	
	inventory_gui_tabs.tab_selected.connect(_on_inventory_gui_tab_selected)
	
	%StateChart/Main/Inventory/Disabled.state_entered.connect(_on_state_entered_inventory_gui_disabled)
	%StateChart/Main/Inventory/Enabled.state_entered.connect(_on_state_entered_inventory_gui_enabled)
	%StateChart/Main/Inventory/Enabled.state_input.connect(_on_state_input_inventory_gui_enabled)
	%StateChart/Main/Inventory/Enabled/Gear.state_entered.connect(_on_state_entered_inventory_gui_gear)
	%StateChart/Main/Inventory/Enabled/Dreamkin.state_entered.connect(_on_state_entered_inventory_gui_dreamkin)
	%StateChart/Main/Inventory/Enabled/Items.state_entered.connect(_on_state_entered_inventory_gui_items)
	%StateChart/Main/Inventory/Enabled/Keys.state_entered.connect(_on_state_entered_inventory_gui_keys)
	
	%StateChart/Main/Inventory/Disabled.state_exited.connect(_on_state_exited_inventory_gui_disabled)
	%StateChart/Main/Inventory/Enabled/Gear.state_exited.connect(_on_state_exited_inventory_gui_gear)
	%StateChart/Main/Inventory/Enabled/Dreamkin.state_exited.connect(_on_state_exited_inventory_gui_dreamkin)
	%StateChart/Main/Inventory/Enabled/Items.state_exited.connect(_on_state_exited_inventory_gui_items)
	%StateChart/Main/Inventory/Enabled/Keys.state_exited.connect(_on_state_exited_inventory_gui_keys)
	
## --- Utility Functions ---

func convert_tab_to_glossary(tab : int):
	for key in Glossary.item_category:
		if Glossary.item_category[key].TAB == tab:
			return Glossary.item_category[key]

func create_button_category_slots(category_title : String):
	
	var button_list : Array
	
	## Pull the dreamkin if it's that cat
	if category_title == Glossary.item_category.DREAMKIN.TITLE:
		var list = my_component_party.get_hybrid_data_all()
		
		## List of items to create, where to put em, who to call when they're pressed, what callables to call
		button_list = Glossary.create_button_slots(list,inventory_gui_item_grid,self,
		"_on_button_pressed_dreamkin",
		"_on_button_enter_hover_dreamkin",
		"_on_button_exit_hover_dreamkin")
	
	## Pull a set of items otherwise
	else:
		var list = my_component_inventory.get_items_from_category(category_title)
		list.sort()
		
		## List of items to create, where to put em, who to call when they're pressed, what callables to call
		button_list = Glossary.create_button_slots(list,inventory_gui_item_grid,self,
		"_on_button_pressed_inventory_item",
		"_on_button_enter_hover_inventory_item",
		"_on_button_exit_hover_inventory_item")
	
	## Now we need to make it look like the item
	for button_slot in button_list:
		var icon_inst = button_slot.properties.item.icon.instantiate()
		button_slot.slot_container.add_child(icon_inst)

func create_button_category_list(category_title : String):
	
	var dict = my_component_inventory.get_items_from_category(category_title)
	dict.sort()
	
	var button_list = Glossary.create_button_list(dict,inventory_gui_item_grid,self,
	"_on_button_pressed_inventory_item",
	"_on_button_enter_hover_inventory_item",
	"_on_button_exit_hover_inventory_item")
	
	for button in button_list:
		## Display
		if button.properties.item.quantity > 1:
			button.text = str(button.properties.item.title,"  x",button.properties.item.quantity)
		else:
			button.text = button.properties.item.title

func refresh():
	var prev = inventory_gui_tabs.current_tab
	state_chart.send_event("on_gui_disabled")
	state_chart.send_event("on_gui_enabled")
	inventory_gui_tabs.current_tab = prev

func options_close():
	inventory_gui_options_barrier.hide()
	inventory_gui_options_panel.hide()
	Glossary.free_children(inventory_gui_options_list)
	refresh.call_deferred()

func options_create_list(properties : Dictionary):
	
	var item = properties.item
	
	Glossary.free_children(inventory_gui_options_list)
	
	## Placing options window near the relevant item in the list
	var pos_button = Vector2.ZERO
	## Grab position of button we clicked
	for child in inventory_gui_item_grid.get_children():
		if child.properties.item == item:
			pos_button = child.global_position + Vector2(0,child.get_size().y)
	## Adjusting position. Makes it easier to click and see. Displays directly below selected item
	inventory_gui_options_panel.global_position = pos_button
	
	Glossary.create_options_list(properties,inventory_gui_options_list,self,"_on_button_pressed_inventory_item_option","world")
		
	inventory_gui_options_panel.show()
	inventory_gui_options_barrier.show()

## --- Buttons ---

## Changing states tabs

func _on_inventory_gui_tab_selected(tab : int):
	match convert_tab_to_glossary(tab):
		Glossary.item_category["GEAR"]:
			state_chart.send_event("on_gui_gear")
		Glossary.item_category["DREAMKIN"]:
			state_chart.send_event("on_gui_dreamkin")
		Glossary.item_category["ITEMS"]:
			state_chart.send_event("on_gui_items")
		Glossary.item_category["KEYS"]:
			state_chart.send_event("on_gui_keys")

## Item buttons

func _on_button_pressed_inventory_item(properties : Dictionary):
	options_create_list(properties)

func _on_button_enter_hover_inventory_item(properties : Dictionary):
	
	var item = properties.item
	
	var dict = Glossary.convert_info_item_gui(item)
	
	inventory_gui_item_grid_info_label.text = dict.header
	inventory_gui_item_grid_info_description_label.text = dict.description
	
	inventory_gui_item_grid_info.show()
	
func _on_button_exit_hover_inventory_item(properties : Dictionary):
	inventory_gui_item_grid_info.hide()

## Dreamkin buttons

func _on_button_pressed_dreamkin(properties : Dictionary):
	options_create_list(properties)

func _on_button_enter_hover_dreamkin(properties : Dictionary):
	
	var dreamkin = Glossary.convert_info_character_gui(properties.item)
	inventory_gui_item_grid_info_label.text = dreamkin.header
	inventory_gui_item_grid_info_description_label.text = dreamkin.description
	
	inventory_gui_item_grid_info.show()

func _on_button_exit_hover_dreamkin(properties : Dictionary):
	inventory_gui_item_grid_info.hide()

## Option buttons

func _on_button_pressed_inventory_item_option(properties : Dictionary):
	
	var result = Glossary.evaluate_option_properties(properties,inventory_gui_options_list,self,
	"_on_button_pressed_inventory_item_option",
	"world",
	"_on_button_enter_hover_inventory_item_option",
	"_on_button_exit_hover_inventory_item_option"
	)
	
	if result == Glossary.options_result.FINISHED:
		options_close()

func _on_button_enter_hover_inventory_item_option(properties : Dictionary):
	
	if "info" in properties:
		var dict = Glossary.convert_info_universal_gui(properties.info)
		inventory_gui_item_grid_info_label.text = dict.header
		inventory_gui_item_grid_info_description_label.text = dict.description
		inventory_gui_item_grid_info.show()

func _on_button_exit_hover_inventory_item_option(properties : Dictionary):
	inventory_gui_item_grid_info.hide()

### --- STATES --- ###

## Enabled

func _on_state_entered_inventory_gui_enabled():
	inventory_gui.show()

func _on_state_input_inventory_gui_enabled(event : InputEvent) -> void:
	
	if Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("ui_cancel"):
		if inventory_gui_options_barrier.visible:
			options_close()
		else:
			state_chart.send_event("on_gui_disabled") #Disable the inventory
			owner.state_chart.send_event("on_enabled") #Enable the player
		
	elif Input.is_action_just_pressed("interact"):
		inventory_gui_tabs.select_next_available()
	
	elif Input.is_action_just_pressed("interact_secondary"):
		inventory_gui_tabs.select_previous_available()

## Disabled

func _on_state_entered_inventory_gui_disabled():
	inventory_gui.hide()
	inventory_gui_item_grid_info.hide() #Hide description panel
	inventory_gui_options_barrier.hide() #Hide options blocker if it was open
	inventory_gui_options_panel.hide() #Hide options if it was open
	inventory_gui_tabs.current_tab = 0 #Reset tabs to first
	Glossary.free_children(inventory_gui_item_grid)
	Glossary.free_children(inventory_gui_options_list)
	
func _on_state_exited_inventory_gui_disabled():
	pass

## Gear

func _on_state_entered_inventory_gui_gear():
	Glossary.free_children(inventory_gui_item_grid)
	create_button_category_slots(Glossary.item_category.GEAR.TITLE)
	
func _on_state_exited_inventory_gui_gear():
	pass

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	Glossary.free_children(inventory_gui_item_grid)
	create_button_category_slots(Glossary.item_category.DREAMKIN.TITLE)

func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func _on_state_entered_inventory_gui_items():
	Glossary.free_children(inventory_gui_item_grid)
	create_button_category_slots(Glossary.item_category.ITEMS.TITLE)
	
func _on_state_exited_inventory_gui_items():
	pass

## Keys

func _on_state_entered_inventory_gui_keys():
	Glossary.free_children(inventory_gui_item_grid)
	create_button_category_list(Glossary.item_category.KEYS.TITLE)

func _on_state_exited_inventory_gui_keys():
	pass
