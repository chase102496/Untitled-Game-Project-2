extends Control

@onready var selector_list : Array
@onready var selected_ability : Object
@onready var selected_target : Object

@onready var selector_sprite : Node = $selector_sprite

@onready var ui_panel_menu : Node = %Menu #Panel Container containing Menu

@onready var ui_grid_main : Node = %Menu/Main #The screen that shows battle, items, switch, escape
@onready var ui_grid_battle : Node = %Menu/Battle #The screen that shows abilities
@onready var ui_grid_switch : Node = %Menu/Switch #The screen that shows dreamkin
#@onready var ui_grid_item : Node = %Menu/Main/Item #The screen that shows items

@onready var ui_skillcheck : Node = %Skillcheck
@onready var ui_skillcheck_cursor : Node = %Skillcheck/Cursor/RayCast2D
@onready var ui_skillcheck_cursor_anim : Node = %Skillcheck/Cursor/AnimationPlayer
@onready var ui_skillcheck_result : String = ""

@onready var ui_button_battle : Node = %Menu/Main/Battle
@onready var ui_button_switch : Node = %Menu/Main/Switch
@onready var ui_button_item : Node = %Menu/Main/Item
@onready var ui_button_escape : Node = %Menu/Main/Escape

@onready var ui_description_box : PanelContainer = %Description
@onready var ui_description_label : RichTextLabel = %"Description/VBoxContainer/Description Label"

@onready var ui_button_battle_ability : PackedScene = preload("res://UI/empty_ability_button.tscn")
@onready var ui_button_switch_dreamkin : PackedScene = preload("res://UI/empty_dreamkin_button.tscn")

@onready var state_chart : StateChart = %StateChart

signal button_pressed_switch_dreamkin(dreamkin : Object)

func _ready() -> void:
	##UI Hiding
	ui_skillcheck.hide()
	ui_description_box.hide()
	ui_panel_menu.hide()
	#
	ui_grid_main.hide()
	ui_grid_battle.hide()
	ui_grid_switch.hide()
	## Buttons
	ui_button_battle.pressed.connect(_on_button_pressed_battle)
	ui_button_escape.pressed.connect(_on_button_pressed_escape)
	ui_button_switch.pressed.connect(_on_button_pressed_switch)
	ui_button_item.pressed.connect(_on_button_pressed_item)
	## Main
	Events.button_pressed_battle_ability.connect(_on_button_pressed_battle_ability)
	button_pressed_switch_dreamkin.connect(_on_button_pressed_switch_dreamkin)
	%StateChart/Battle_GUI/Main.state_entered.connect(_on_state_entered_battle_gui_main)
	%StateChart/Battle_GUI/Main.state_exited.connect(_on_state_exited_battle_gui_main)
	%StateChart/Battle_GUI/Disabled.state_entered.connect(_on_state_entered_battle_gui_disabled)
	%StateChart/Battle_GUI/Disabled.state_exited.connect(_on_state_exited_battle_gui_disabled)
	## Battle
	%StateChart/Battle_GUI/Battle.state_entered.connect(_on_state_entered_battle_gui_battle)
	%StateChart/Battle_GUI/Battle.state_physics_processing.connect(_on_state_physics_processing_battle_gui_battle)
	%StateChart/Battle_GUI/Battle.state_exited.connect(_on_state_exited_battle_gui_battle)
	%StateChart/Battle_GUI/Select.state_entered.connect(_on_state_entered_battle_gui_select)
	%StateChart/Battle_GUI/Select.state_exited.connect(_on_state_exited_battle_gui_select)
	%StateChart/Battle_GUI/Select.state_physics_processing.connect(_on_state_physics_processing_battle_gui_select)
	%StateChart/Battle_GUI/Skillcheck.state_entered.connect(_on_state_entered_battle_gui_skillcheck)
	%StateChart/Battle_GUI/Skillcheck.state_physics_processing.connect(_on_state_physics_processing_battle_gui_skillcheck) #long af
	%StateChart/Battle_GUI/Skillcheck.state_exited.connect(_on_state_exited_battle_gui_skillcheck)
	Events.skillcheck_hit.connect(_on_skillcheck_hit)
	## Switch
	%StateChart/Battle_GUI/Switch.state_entered.connect(_on_state_entered_battle_gui_switch)
	%StateChart/Battle_GUI/Switch.state_exited.connect(_on_state_exited_battle_gui_switch)

## --- States ----

func _on_state_entered_battle_gui_disabled():
	hide()
func _on_state_exited_battle_gui_disabled():
	show()

## Main menu

func _on_state_entered_battle_gui_main():
	ui_panel_menu.show() #Show main panel
	ui_grid_main.show() #Show main grid of buttons
func _on_state_exited_battle_gui_main():
	ui_panel_menu.hide() #Hide main panel
	ui_grid_main.hide() #Hide main grid of buttons

## Battle

func _on_state_entered_battle_gui_battle():
	ui_panel_menu.show() #Show main panel
	ui_grid_battle.show() #Show battle grid of buttons
	
	#removing old abilities
	for i in ui_grid_battle.get_child_count():
			ui_grid_battle.get_child(i).queue_free()
	#adding new ones
	for i in len(owner.my_component_ability.my_abilities):
		var new_button = ui_button_battle_ability.instantiate()
		new_button.text = owner.my_component_ability.my_abilities[i].title
		new_button.ability = owner.my_component_ability.my_abilities[i]
		new_button.description_box = ui_description_box
		new_button.description_label = ui_description_label
		ui_grid_battle.add_child(new_button)
		new_button.show() #Show buttons

func _on_state_physics_processing_battle_gui_battle(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_gui_main")

func _on_state_exited_battle_gui_battle():
	ui_panel_menu.hide() #Hide main panel
	ui_grid_battle.hide() #Hide battle grid of buttons

# Select target

func _on_state_entered_battle_gui_select():
	selected_target = selector_list[0]
	update_selector_position()
	selector_sprite.show()

func update_selector_position() -> void:
	selector_sprite.global_position.x = selected_target.animations.selector_anchor.global_position.x
	selector_sprite.global_position.y = selected_target.animations.selector_anchor.global_position.y
	selector_sprite.global_position.z = selected_target.animations.selector_anchor.global_position.z

func _on_state_physics_processing_battle_gui_select(delta: float) -> void:

	#Selector hand logic
	var new_index = 0
	
	update_selector_position()
	
	if Input.is_action_just_pressed("move_right"):
		new_index = wrapi(selector_list.find(selected_target,0) + 1,0,len(selector_list))
		selected_target = selector_list[new_index]
	elif Input.is_action_just_pressed("move_left"):
		new_index = wrapi(selector_list.find(selected_target,0) - 1,0,len(selector_list))
		selected_target = selector_list[new_index]

	#Other
	
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_gui_battle")
	
	if Input.is_action_just_pressed("ui_select"):
		owner.my_component_ability.cast_queue = selected_ability #Set the spell for casting
		
		selected_ability.primary_target = selected_target
		selected_ability.targets = Battle.get_target_selector_list(
			selected_target,
			selected_ability.target_selector,
			Battle.get_target_type_list(owner,selected_ability.target_type,true)
			)
		owner.state_chart.send_event("on_skillcheck") #Run skillcheck
		state_chart.send_event("on_gui_skillcheck") #End of GUI stuff
		selector_sprite.hide()

func _on_state_exited_battle_gui_select():
	selected_target = selector_list[0]
	selector_sprite.hide()

# Skillcheck
	
func _on_state_entered_battle_gui_skillcheck():
	ui_skillcheck.show()
	ui_skillcheck_cursor_anim.speed_scale = owner.my_component_ability.skillcheck_difficulty

func _on_state_physics_processing_battle_gui_skillcheck(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_select"):
		ui_skillcheck_cursor_anim.pause()
		
		if ui_skillcheck_cursor.is_colliding():
			ui_skillcheck_result = ui_skillcheck_cursor.get_collider().name
		else:
			ui_skillcheck_result = "Miss"
		
		match ui_skillcheck_result:
			"Miss" : Glossary.create_text_particle(owner.animations.selector_anchor,str("Whoops..."),"float_away",Color.SLATE_GRAY,0,20)
			"Good" : Glossary.create_text_particle(owner.animations.selector_anchor,str("Nice!"),"float_away",Color.SKY_BLUE,0,30)
			"Great" : Glossary.create_text_particle(owner.animations.selector_anchor,str("Great!"),"float_away",Color.MEDIUM_SLATE_BLUE,0,40)
			"Excellent" : Glossary.create_text_particle(owner.animations.selector_anchor,str("Excellent!"),"float_away",Color.PURPLE,0,50)
		
		await get_tree().create_timer(1.0).timeout

		state_chart.send_event("on_gui_disabled")
		owner.state_chart.send_event("on_execution")

func _on_skillcheck_hit(area,ability_queued):
	pass

func _on_state_exited_battle_gui_skillcheck():
	ui_skillcheck.hide()
	ui_skillcheck_cursor_anim.play()

## Switch

func _on_state_entered_battle_gui_switch():
	ui_panel_menu.show()
	ui_grid_switch.show()
	
	#removing old dreamkin buttons
	for i in ui_grid_switch.get_child_count():
			ui_grid_switch.get_child(i).button_pressed_switch_dreamkin.disconnect(_on_button_pressed_switch_dreamkin)
			ui_grid_switch.get_child(i).queue_free()
	#adding new ones
	for i in Global.player.my_component_party.my_party.size(): #TODO Won't work if player is dead rn
		var new_button = ui_button_switch_dreamkin.instantiate()
		new_button.text = Global.player.my_component_party.my_party[i].name
		new_button.dreamkin = Global.player.my_component_party.my_party[i]
		new_button.description_box = ui_description_box
		new_button.description_label = ui_description_label
		ui_grid_switch.add_child(new_button)
		new_button.show() #Show buttons
		new_button.button_pressed_switch_dreamkin.connect(_on_button_pressed_switch_dreamkin)

func _on_state_exited_battle_gui_switch():
	ui_panel_menu.hide()
	ui_grid_switch.hide()

## --- Buttons ---

## Battle

func _on_button_pressed_battle():
	state_chart.send_event("on_gui_battle")
	#TODO add back button for GUIs

func _on_button_pressed_battle_ability(ability : Object):
	if ability.caster == owner:
		selector_list = []
		selected_ability = ability #for use later
		
		if ability.select_validate():
			selector_list = Battle.get_target_type_list(owner,selected_ability.target_type,true)
			state_chart.send_event("on_gui_select")
		else:
			ability.select_validate_failed()

## Switch

func _on_button_pressed_switch():
	##Verify we can switch Dreamkin
	#Later this will include a debuff where we can't swap too
	if Global.player.my_component_party.my_party.size() > 0:
		state_chart.send_event("on_gui_switch")
	else:
		print_debug("No party members to swap to!")

func _on_button_pressed_switch_dreamkin(dreamkin : Object):
	
	if dreamkin.select_validate(): #They are eligible to go into battle
		
		var dreamkin_list = Battle.search_classification("DREAMKIN",Battle.alignment.FRIENDS) #Find other Dreamkin in battle on our team
		
		if dreamkin_list.size() > 1: #Impossible or bug, should only have 1 active dreamkin
			push_error("ERROR: Detecting >2 Dreamkin on Battlefield - ",dreamkin_list)
		else:
			if dreamkin_list.size() == 1: #There is another active dreamkin
				var old_dreamkin = dreamkin_list[0]
				var old_dreamkin_battle_index = Battle.battle_list.find(old_dreamkin) #Grab the battle index for the old dreamkin we are swapping out
				var new_dreamkin_inst = Global.player.my_component_party.summon(Global.player.my_component_party.my_party.find(dreamkin),"battle") #Find new dreamkin's index, and summon it
				Battle.replace_member(new_dreamkin_inst,old_dreamkin_battle_index) #Update battle list to include that new summon
				
				print(Global.player.my_component_party.my_party.find(old_dreamkin))
				
				Global.player.my_component_party.recall(Global.player.my_component_party.my_summons.find(old_dreamkin)) #Find the old dreamkin that was on the field and recall it
				
			else: #No dreamkin on battlefield
				
				if Global.player in Battle.battle_list: #If our player is alive still
					Battle.add_member(dreamkin,Battle.battle_list.find(Global.player)+1) #Add us after player
					
				else: #We are the last one (somehow)
					Battle.add_member(dreamkin,0)
			
			print_debug("Swapping out Dreamkin...")
			
			state_chart.send_event("on_gui_disabled") #Disable gui
			Events.turn_end.emit.call_deferred() #End turn without any phases
			#owner.state_chart.send_event("on_end") #End our turn

func _on_button_pressed_item():
	pass

## Escape

func _on_button_pressed_escape():
	SceneManager.transition_to_prev()
