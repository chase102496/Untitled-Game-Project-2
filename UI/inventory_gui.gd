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

#Working on: Adding buttons for each item in the inventory tab.
#empty_item_button.gd
#inventory_gui.gd
#component_inventory.gd
#Next steps:
#- Connect the button signal to the inventory manager.
#- Test item interactions when a button is clicked.
#- Figuring out how to display the sprite. TextureRect or Code my own display method for animated sprites?

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

func convert_tab_to_glossary(tab : int):
	for key in Glossary.item_category:
		if Glossary.item_category[key].TAB == tab:
			return key

func clear_inventory_options():
	for child in inventory_gui_options_list.get_children():
			child.queue_free()

## --- Buttons ---

## Items

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

func _on_button_pressed_inventory_item(item : Object):
	
	clear_inventory_options()
	
	## Placing options window near the relevant item in the list
	var pos_button = Vector2.ZERO
	
	## Grab position of button we clicked
	for child in inventory_gui_item_list.get_children():
		if child.item == item:
			pos_button = child.global_position
	
	## Just adjusting position. Makes it easier to click and see. Displays directly below selected item
	inventory_gui_options_panel.global_position = pos_button + (Vector2(0,inventory_gui_options_panel.get_size().y)/2)
	
	## Make button for each option
	for option in item.options_world:
		var new_button = ui_button_inventory_item_option.instantiate()
		new_button.option = option
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

## Item Options

func _on_button_pressed_inventory_item_option(item : Object, option : String, target : Node):
	
	
	
	##If we're selecting a target to use the item on, and we've already picked an option
	#if target:
		#item.options_world[option].call(target) #call(chosen_character)
		#inventory_gui_options.hide()
	##If we need to check if there's targets to calculate before immediately using the item
	#elif "valid_targets" in item.options_world[option]:
		#
		#var results : Array = []
		#
		### Run through the array of all classification types
		#for classification in item.options_world[option]:
			###Iterate through live dreamkin and their classification
			#for dreamkin in Global.player.my_component_party.get_hybrid_data_all():
				#if dreamkin.classification in item.options_world[option]["valid_targets"]:
					#results.append(dreamkin)
			#if Global.player in item.options_world[option]["valid_targets"]:
				#results.append(Global.player)
		#
		#clear_inventory_options()
		#
		#for result in results:
			#var new_button = ui_button_inventory_item_option.instantiate()
			#new_button.option = option
			#new_button.item = item
			#new_button.target = result
			#inventory_gui_options_list.add_child(new_button)
	#
	### If we can just immediately use the item
	#else:
		item.options_world[option]["script"].call()
		inventory_gui_options.hide()

## --- States ---

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
	
	for item in my_component_inventory.get_items_from_category(Glossary.item_category.GEAR):
		var new_button = ui_button_inventory_item.instantiate()
		new_button.item = item
		inventory_gui_item_list.add_child(new_button)
		new_button.show()
	
func _on_state_exited_inventory_gui_gear():
	
	for child in inventory_gui_item_list.get_children():
		child.queue_free()

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	pass

func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func refresh():
	var prev = inventory_gui_tabs.current_tab
	state_chart.send_event("on_gui_toggle")
	state_chart.send_event("on_gui_toggle")
	inventory_gui_tabs.current_tab = prev

func _on_state_entered_inventory_gui_items():
	
	for item in my_component_inventory.get_items_from_category(Glossary.item_category.ITEMS):
		var new_button = ui_button_inventory_item.instantiate()
		new_button.item = item
		inventory_gui_item_list.add_child(new_button)
		new_button.show()
	
func _on_state_exited_inventory_gui_items():

	for child in inventory_gui_item_list.get_children():
		child.queue_free()

## Keys

func _on_state_entered_inventory_gui_keys():
	pass
func _on_state_exited_inventory_gui_keys():
	pass
	
