extends Control

@export var my_component_inventory : component_inventory
@onready var inventory_gui_list = $PanelContainer/VBoxContainer/Panel/View/ScrollContainer/List
@onready var inventory_gui_list_info = $PanelContainer/VBoxContainer/Panel/View/Info
@onready var inventory_gui_tabs = %Tabs

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
	inventory_gui_tabs.tab_selected.connect(_on_inventory_gui_tab_selected)
	Events.button_pressed_inventory_item.connect(_on_button_pressed_inventory_item)
	
	%StateChart/Inventory_GUI/Disabled.state_entered.connect(_on_state_entered_inventory_gui_disabled)
	%StateChart/Inventory_GUI/Enabled.state_entered.connect(_on_state_entered_inventory_gui_enabled)
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

## --- Buttons ---
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
	pass

## --- States ---

## Enabled

func _on_state_entered_inventory_gui_enabled():
	show()

## Disabled

func _on_state_entered_inventory_gui_disabled():
	hide()
func _on_state_exited_inventory_gui_disabled():
	pass

## Gear

func _on_state_entered_inventory_gui_gear():
	
	for item in my_component_inventory.my_items:
		var new_button = item
	
func _on_state_exited_inventory_gui_gear():
	pass

## Dreamkin

func _on_state_entered_inventory_gui_dreamkin():
	pass
func _on_state_exited_inventory_gui_dreamkin():
	pass

## Items

func _on_state_entered_inventory_gui_items():
	pass
func _on_state_exited_inventory_gui_items():
	pass

## Keys

func _on_state_entered_inventory_gui_keys():
	pass
func _on_state_exited_inventory_gui_keys():
	pass
	
