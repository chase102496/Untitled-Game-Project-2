class_name world_gui
extends GUI

signal inventory_opened
signal equipment_changed
var previous_equipment : component_world_ability.world_ability
#listen externally for usability of keys and animations

@export var my_component_party : component_party
@export var my_component_inventory : component_inventory
@export var my_component_world_ability : component_world_ability

### --- HUD --- ###

@onready var hud_gui = %HUD
@onready var hud_gui_keyboard_R = $HUD/VBoxContainer/icon_2d_keyboard_R
@onready var hud_gui_keyboard_Q = $HUD/VBoxContainer/icon_2d_keyboard_Q
@onready var hud_gui_keyboard_I = $HUD/VBoxContainer/icon_2d_keyboard_I
@onready var hud_gui_ability_slot = $HUD/VBoxContainer/icon_2d_keyboard_R/Ability

### --- Inventory --- ###

@onready var inventory_gui = %Inventory
@onready var inventory_gui_tabs = %Tabs

## Content
@onready var inventory_gui_item_grid = %ContentGrid

## Info
@onready var inventory_gui_info = %Info
@onready var inventory_gui_info_icon_slot = inventory_gui_info.icon_slot
@onready var inventory_gui_info_title = inventory_gui_info.title
@onready var inventory_gui_info_description = inventory_gui_info.description

## Options
@onready var inventory_gui_options_barrier = %Inventory/Main/Content/Options
@onready var inventory_gui_options_panel = %Submenu
@onready var inventory_gui_options_list = %Submenu/List

@onready var state_chart : StateChart = %StateChart

func _ready() -> void:
	
	### --- HUD --- ###
	if my_component_world_ability:
		my_component_world_ability.used_ability.connect(_on_hud_used_ability)
		my_component_world_ability.equip_update.connect(_on_hud_equip_update)
		my_component_world_ability.equip_active.connect(_on_hud_equip_active)
		my_component_world_ability.equip_inactive.connect(_on_hud_equip_inactive)
		my_component_world_ability.equip_set.connect(_on_hud_equip_set)
		my_component_world_ability.equip_unset.connect(_on_hud_equip_unset)
		hud_gui_keyboard_Q.hide()
		hud_gui_keyboard_R.hide()
	
	### --- Inventory --- ###
	
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

#func _create_button_category_slots(category_title : String) -> void:
	#
	#var button_list : Array
	#
	### Pull the dreamkin if it's that cat
	### This is so we don't sort it weirdly
	#if category_title == Glossary.item_category.DREAMKIN.TITLE:
		#var list = my_component_party.get_hybrid_data_all()
		#
		### List of items to create, where to put em, who to call when they're pressed, what callables to call
		#button_list = Glossary.create_button_slots(list,inventory_gui_item_grid,self,
		#"_on_button_pressed_dreamkin",
		#"_on_button_enter_hover_dreamkin",
		#"_on_button_exit_hover_dreamkin")
	#
	### Pull a set of items otherwise
	#else:
		#var list = my_component_inventory.get_items_from_category(category_title)
		#list.sort()
		#
		### List of items to create, where to put em, who to call when they're pressed, what callables to call
		#button_list = Glossary.create_button_slots(list,inventory_gui_item_grid,self,
		#"_on_button_pressed_inventory_item",
		#"_on_button_enter_hover_inventory_item",
		#"_on_button_exit_hover_inventory_item")
	#
	### Now we need to make it look like the item
	#for button_slot in button_list:
		#var icon_inst = button_slot.properties.item.icon.instantiate()
		#button_slot.slot_container.add_child(icon_inst)
		#
		### This is where we customize the slots based on item properties
		#if button_slot.properties.item.get("my_world_ability"):
			##If stackable, get the quantity and display it in the corner of the slot!
			#if button_slot.properties.item.my_world_ability.is_in_equipment():
				#button_slot.button.modulate = Global.palette["Medium Slate Blue"]

func refresh() -> void:
	if inventory_gui.visible:
		## Clear item slot in desc panel
		Global.clear_children(inventory_gui_info_icon_slot)
		## Saving tab so when we close inv we don't lose tab
		## And then closing and opening inventory to update
		var prev = inventory_gui_tabs.current_tab
		state_chart.send_event("on_gui_disabled")
		state_chart.send_event("on_gui_enabled")
		inventory_gui_tabs.current_tab = prev

func _options_close() -> void:
	inventory_gui_options_barrier.hide()
	inventory_gui_options_panel.hide()
	inventory_gui_info.hide()
	Glossary.free_children(inventory_gui_options_list)
	refresh.call_deferred()

func _options_create_list(properties : Dictionary) -> void:
	
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

### --- HUD --- ###

## We updated equipment, but didn't change which one is equipped
## For icon updates and such
func _on_hud_equip_update(ability : component_world_ability.world_ability) -> void:
	Global.clear_children(hud_gui_ability_slot)
	hud_gui_ability_slot.add_child(ability.icon.instantiate())

##
func _on_hud_used_ability(ability : component_world_ability.world_ability) -> void:
	pass

## Something is now our active ability
func _on_hud_equip_active(new_ability : component_world_ability.world_ability) -> void:
	hud_gui_keyboard_R.show()
	hud_gui_keyboard_Q.show()
	Global.clear_children(hud_gui_ability_slot)
	hud_gui_ability_slot.add_child(new_ability.icon.instantiate())
	equipment_changed.emit()
	refresh()

func _on_hud_equip_inactive(ability : component_world_ability.world_ability) -> void:
	Global.clear_children(hud_gui_ability_slot)
	hud_gui_keyboard_R.hide()
	## If we have no equip to swap to or from
	if my_component_world_ability.get_equipment().is_empty():
		hud_gui_keyboard_Q.hide()
	## If we just swapped to our empty slot
	else:
		hud_gui_keyboard_Q.show()
		equipment_changed.emit()
	
	refresh()

func _on_hud_equip_set(new_ability : component_world_ability.world_ability) -> void:
	hud_gui_keyboard_Q.show()
	
	refresh()

func _on_hud_equip_unset(new_ability : component_world_ability.world_ability) -> void:
	
	if my_component_world_ability.get_equipment().is_empty():
		hud_gui_keyboard_Q.hide()
	
	refresh()

### --- INVENTORY --- ###

## -- Buttons -- ##

## Changing states tabs

func _on_inventory_gui_tab_selected(tab : int):
	inventory_gui_info.hide()
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
	if properties.item.options_world:
		_options_create_list(properties)

func _on_button_enter_hover_inventory_item(properties : Dictionary):
	_set_info(properties,inventory_gui_info_icon_slot, inventory_gui_info_title, inventory_gui_info_description)
	inventory_gui_info.show()
	
func _on_button_exit_hover_inventory_item(properties : Dictionary):
	pass

## Dreamkin buttons

func _on_button_pressed_dreamkin(properties : Dictionary):
	_options_create_list(properties)

func _on_button_enter_hover_dreamkin(properties : Dictionary):
	_set_info(properties,inventory_gui_info_icon_slot, inventory_gui_info_title, inventory_gui_info_description)
	inventory_gui_info.show()

func _on_button_exit_hover_dreamkin(properties : Dictionary):
	inventory_gui_info.hide()

## Option buttons

func _on_button_pressed_inventory_item_option(properties : Dictionary):
	
	var result = Glossary.evaluate_option_properties(properties,inventory_gui_options_list,self,
	"_on_button_pressed_inventory_item_option",
	"world",
	"_on_button_enter_hover_inventory_item_option",
	"_on_button_exit_hover_inventory_item_option"
	)
	
	if result == Glossary.options_result.FINISHED:
		_options_close()

func _on_button_enter_hover_inventory_item_option(properties : Dictionary):
	_set_info(properties,inventory_gui_info_icon_slot, inventory_gui_info_title, inventory_gui_info_description)
	inventory_gui_info.show()

func _on_button_exit_hover_inventory_item_option(properties : Dictionary):
	pass

### --- STATES --- ###

## Enabled

func _on_state_entered_inventory_gui_enabled():
	inventory_gui.show()
	inventory_opened.emit()

func _on_state_input_inventory_gui_enabled(event : InputEvent) -> void:
	
	if Input.is_action_just_pressed("inventory") or Input.is_action_just_pressed("ui_cancel"):
		if inventory_gui_options_barrier.visible:
			_options_close()
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
	inventory_gui_info.hide() #Hide description panel
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
	_create_button_category_slots(my_component_inventory.get_items_from_category(Glossary.item_category.GEAR.TITLE),inventory_gui_item_grid,"inventory_item")
	
func _on_state_exited_inventory_gui_gear():
	pass

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	Glossary.free_children(inventory_gui_item_grid)
	_create_button_category_slots(my_component_party.get_hybrid_data_all(),inventory_gui_item_grid,"dreamkin")
	

func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func _on_state_entered_inventory_gui_items():
	Glossary.free_children(inventory_gui_item_grid)
	_create_button_category_slots(my_component_inventory.get_items_from_category(Glossary.item_category.ITEMS.TITLE),inventory_gui_item_grid,"inventory_item")
	
func _on_state_exited_inventory_gui_items():
	pass

## Keys

func _on_state_entered_inventory_gui_keys():
	Glossary.free_children(inventory_gui_item_grid)
	_create_button_category_slots(my_component_inventory.get_items_from_category(Glossary.item_category.KEYS.TITLE),inventory_gui_item_grid,"inventory_item")

func _on_state_exited_inventory_gui_keys():
	pass
