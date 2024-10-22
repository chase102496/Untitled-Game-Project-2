extends Control

@onready var selector_list : Array
@onready var selected_ability : Object
@onready var selected_target : Object
@onready var selector_sprite : Node = $Sprite3D

@onready var ui_grid_main = $Container/Panel1/Main
@onready var ui_grid_battle = $Container/Panel1/Battle
#@onready var ui_grid_switch = $Container/Panel1/Switch
#@onready var ui_grid_item = $Container/Panel1/Item

@onready var ui_button_battle = $Container/Panel1/Main/Battle
@onready var ui_button_switch = $Container/Panel1/Main/Switch
@onready var ui_button_item = $Container/Panel1/Main/Item
@onready var ui_button_escape = $Container/Panel1/Main/Escape

@onready var ui_button_battle_ability = preload("res://scenes/empty_ability_button.tscn")

@onready var state_chart: StateChart = get_node("StateChart")

#have it remove the UI when our state is exited
#have it show our state when it is entered

func _ready() -> void:
	
	#position.x += randi_range(100,200) just to make sure there's no duplicate menus up
	#position.y -= randi_range(100,200)
	#connect to button signals
	ui_button_battle.pressed.connect(_on_button_pressed_battle)
	
	# TODO Sets up our abilities in the ui
	#for i in $Container/Panel1/Battle.get_child_count():
		#ui_grid_battle.get_child(i).text = get_parent().my_abilities[i]
	#
	ui_button_switch.pressed.connect(_on_button_pressed_switch)
	#
	ui_button_item.pressed.connect(_on_button_pressed_item)
	#
	ui_button_escape.pressed.connect(_on_button_pressed_escape)
	#
	#connect to enter and exit for start
	Events.battle_gui_button_pressed.connect(_on_button_pressed_battle_ability)
	get_node("StateChart/Battle GUI/Main").state_entered.connect(_on_state_entered_battle_gui_main)
	get_node("StateChart/Battle GUI/Main").state_exited.connect(_on_state_exited_battle_gui_main)
	get_node("StateChart/Battle GUI/Battle").state_entered.connect(_on_state_entered_battle_gui_battle)
	get_node("StateChart/Battle GUI/Battle").state_exited.connect(_on_state_exited_battle_gui_battle)
	get_node("StateChart/Battle GUI/Select").state_entered.connect(_on_state_entered_battle_gui_select)
	get_node("StateChart/Battle GUI/Select").state_physics_processing.connect(_on_state_physics_processing_battle_gui_select)
	get_node("StateChart/Battle GUI/Select").state_exited.connect(_on_state_exited_battle_gui_select)
	get_node("StateChart/Battle GUI/Disabled").state_entered.connect(_on_state_entered_battle_gui_disabled)
	get_node("StateChart/Battle GUI/Disabled").state_exited.connect(_on_state_exited_battle_gui_disabled)

# -------------------------------------------

func _on_state_entered_battle_gui_disabled():
	hide()
func _on_state_exited_battle_gui_disabled():
	if len(Battle.get_team("foes")) == 0: #TODO Make an end battle screen? Nah actually
		owner.state_chart.send_event("on_idle")
	elif len(Battle.get_team("friends")) == 0:
		owner.state_chart.send_event("on_finished") #TODO RIP, you lost or fainted or whatever, what do?
	else:
		show()

func _on_state_entered_battle_gui_main():
	ui_grid_main.show()
func _on_state_exited_battle_gui_main():
	ui_grid_main.hide()
func _on_state_entered_battle_gui_battle(): #TODO maybe later make this flexible to both player and companion
	ui_grid_battle.show()
	
	#removing old abilities
	for i in ui_grid_battle.get_child_count():
			ui_grid_battle.get_child(i).queue_free()
	#adding new ones
	for i in len(owner.my_component_ability.my_abilities):
		var new_button = ui_button_battle_ability.instantiate()
		new_button.text = owner.my_component_ability.my_abilities[i].title
		new_button.ability = owner.my_component_ability.my_abilities[i]
		new_button.show()
		ui_grid_battle.add_child(new_button)

func _on_state_exited_battle_gui_battle():
	ui_grid_battle.hide()

func _on_state_entered_battle_gui_select():
	hide()
	if !selector_sprite.visible:
			selector_sprite.show()
	selected_target = selector_list[0]

func _on_state_physics_processing_battle_gui_select(delta: float) -> void:
	
	var new_index = 0
	var selector_sprite_offset = 1
	
	selector_sprite.global_position.x = selected_target.global_position.x
	selector_sprite.global_position.y = selected_target.global_position.y + selector_sprite_offset
	selector_sprite.global_position.z = selected_target.global_position.z
	
	if Input.is_action_just_pressed("ui_select"):
		owner.my_component_ability.cast_queue = selected_ability #Set the spell for casting
		selected_ability.target = selected_target #set the spell's target to our gui's target
		owner.state_chart.send_event("on_skillcheck") #Run skillcheck
		state_chart.send_event("on_gui_disabled") #End of GUI stuff #TODO put skillcheck gui next
		selector_sprite.hide()

	if Input.is_action_just_pressed("move_right"):
		new_index = wrapi(selector_list.find(selected_target,0) + 1,0,len(selector_list))
		selected_target = selector_list[new_index]
	elif Input.is_action_just_pressed("move_left"):
		new_index = wrapi(selector_list.find(selected_target,0) - 1,0,len(selector_list))
		selected_target = selector_list[new_index]

func _on_state_exited_battle_gui_select():
	show()

# ------------------------------------------- States ^ and Buttons \/

func _on_button_pressed_battle():
	state_chart.send_event("on_gui_battle")
	#TODO Figure out what to do once ability button is pressed. How to interpret generically
	#Maybe run a generic cast function in the ability once the button is pressed and let it handle the rest
	#TODO add back button for GUIs

func _on_button_pressed_battle_ability(ability):
	
	selector_list = []
	selected_ability = ability #for use later
	
	if ability.validate():
		#TODO check if it is a targetable spell first, if not skip this part
		for i in len(Battle.battle_list): #adds potential targets to our selector list to select a tgt
			var unit = Battle.battle_list[i]
			if unit.stats.alignment == "foes": #add foes first as prio for target
				selector_list.push_front(unit)
			elif unit.stats.alignment in ability.valid_targets: #add others second and prio for target
				selector_list.append(unit)
		state_chart.send_event("on_gui_select")
			
		#signal a new thing to happen
		
		#HACK
		
		#function to select goes here
		
		#after selection
	else:
		ability.validate_failed()
		
		#store obj in memory to cast ability later
		#send state change to owner
	#return if we cannot cast it and get the info from the ability

func _on_button_pressed_switch():
	pass
	
func _on_button_pressed_item():
	pass

func _on_button_pressed_escape():
	pass
