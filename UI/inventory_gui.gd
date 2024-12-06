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

func create_button_category_list(category_title : String):
	
	Glossary.free_children(inventory_gui_item_list)
	
	var dict = my_component_inventory.get_items_from_category(category_title)
	dict.sort()
	
	var button_list = Glossary.create_button_list(dict,inventory_gui_item_list,self,
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
	for child in inventory_gui_item_list.get_children():
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
	
	var dict = Glossary.convert_info_item_gui(item)
	
	inventory_gui_item_list_info_label.text = dict.header
	inventory_gui_item_list_info_description_label.text = dict.description
	
	inventory_gui_item_list_info.show()
	
func _on_button_exit_hover_inventory_item(properties : Dictionary):
	inventory_gui_item_list_info.hide()

## Dreamkin buttons

func _on_button_pressed_dreamkin(properties : Dictionary):
	options_create_list(properties)

func _on_button_enter_hover_dreamkin(properties : Dictionary):
	
	var dreamkin = Glossary.convert_info_character_gui(properties.item)
	inventory_gui_item_list_info_label.text = dreamkin.header
	inventory_gui_item_list_info_description_label.text = dreamkin.description
	
	inventory_gui_item_list_info.show()

func _on_button_exit_hover_dreamkin(properties : Dictionary):
	inventory_gui_item_list_info.hide()

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
		inventory_gui_item_list_info_label.text = dict.header
		inventory_gui_item_list_info_description_label.text = dict.description
		inventory_gui_item_list_info.show()

func _on_button_exit_hover_inventory_item_option(properties : Dictionary):
	inventory_gui_item_list_info.hide()

## ---      STATES      ---

## Enabled

func _on_state_entered_inventory_gui_enabled():
	show()

func _on_state_physics_processing_inventory_gui_enabled(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if inventory_gui_options_barrier.visible:
			options_close()
		else:
			state_chart.send_event("on_gui_disabled") #Disable the inventory
			owner.state_chart.send_event("on_enabled") #Enable the player

## Disabled

func _on_state_entered_inventory_gui_disabled():
	hide()
	inventory_gui_options_barrier.hide() #Hide options blocker if it was open
	inventory_gui_options_panel.hide() #Hide options if it was open
	inventory_gui_tabs.current_tab = 0 #Reset tabs to first
	Glossary.free_children(inventory_gui_item_list)
	Glossary.free_children(inventory_gui_options_list)
	
func _on_state_exited_inventory_gui_disabled():
	pass

## Gear

func _on_state_entered_inventory_gui_gear():
	Glossary.free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.GEAR.TITLE)
	
func _on_state_exited_inventory_gui_gear():
	pass

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	Glossary.free_children(inventory_gui_item_list)
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
	Glossary.free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.ITEMS.TITLE)
	
func _on_state_exited_inventory_gui_items():
	pass

## Keys

func _on_state_entered_inventory_gui_keys():
	Glossary.free_children(inventory_gui_item_list)
	create_button_category_list(Glossary.item_category.KEYS.TITLE)

func _on_state_exited_inventory_gui_keys():
	pass
