class_name battle_gui
extends Control

@export var active_portrait : Control
@onready var portrait_list : Array = $Portraits.get_children() #TODO REMOVE THIS

@onready var selector_list : Array
@onready var selected_ability : Object
@onready var selected_target : Object

#@onready var selector_sprite : Node = $selector_sprite

@onready var ui_panel_menu : Node = %Menu #Panel Container containing Menu

@onready var ui_grid_main : Node = %Menu/Main #The screen that shows echoes, items, party, escape
@onready var ui_grid_echoes : Node = %Menu/Echoes #The screen that shows abilities
@onready var ui_grid_party : Node = %Menu/Party #The screen that shows dreamkin
@onready var ui_grid_items : Node = %Menu/Items #The screen that shows items

@onready var ui_skillcheck : Node = %Skillcheck
@onready var ui_skillcheck_cursor : Node = %Skillcheck/Cursor/RayCast2D
@onready var ui_skillcheck_cursor_anim : Node = %Skillcheck/Cursor/AnimationPlayer
@onready var ui_skillcheck_result : String = ""

@onready var ui_button_attack : Node = %Menu/Main/Attack/Button
@onready var ui_button_echoes : Node = %Menu/Main/Echoes/Button
@onready var ui_button_party : Node = %Menu/Main/Party/Button
@onready var ui_button_items : Node = %Menu/Main/Items/Button
@onready var ui_button_escape : Node = %Menu/Main/Escape/Button

@onready var ui_description_box : PanelContainer = %Description
@onready var ui_description_title : RichTextLabel = %"Description/VBoxContainer/Description Title"
@onready var ui_description_label : RichTextLabel = %"Description/VBoxContainer/Description Label"

@onready var ui_input_prompt_Q : Control = $"Input Prompts/icon_2d_keyboard_Q"
@onready var ui_input_prompt_SPACE : Control = $"Input Prompts/icon_2d_keyboard_SPACE"
@onready var ui_input_prompt_SPACE_ATTACK : Control = $"Input Prompts/icon_2d_keyboard_SPACE/icon_sword_default"
@onready var ui_input_prompt_SPACE_DEFEND : Control = $"Input Prompts/icon_2d_keyboard_SPACE/icon_shield_default"

@onready var state_chart : StateChart = %StateChart

func _ready() -> void:

	## Main
	ui_grid_main.hide()
	%StateChart/Battle_GUI/Main.state_entered.connect(_on_state_entered_battle_gui_main)
	%StateChart/Battle_GUI/Main.state_input.connect(_on_state_input_battle_gui_main)
	%StateChart/Battle_GUI/Main.state_exited.connect(_on_state_exited_battle_gui_main)
	
	## Attack
	ui_button_attack.pressed.connect(_on_button_pressed_attack)
	
	## Echoes
	ui_grid_echoes.hide()
	ui_button_echoes.pressed.connect(_on_button_pressed_echoes)
	Events.button_pressed_echoes_ability.connect(_on_button_pressed_echoes_ability)
	%StateChart/Battle_GUI/Echoes.state_entered.connect(_on_state_entered_battle_gui_echoes)
	%StateChart/Battle_GUI/Echoes.state_physics_processing.connect(_on_state_physics_processing_battle_gui_echoes)
	%StateChart/Battle_GUI/Echoes.state_exited.connect(_on_state_exited_battle_gui_echoes)
	
	## Party
	if ui_grid_party:
		ui_grid_party.hide()
		ui_button_party.pressed.connect(_on_button_pressed_party)
		%StateChart/Battle_GUI/Party.state_entered.connect(_on_state_entered_battle_gui_party)
		%StateChart/Battle_GUI/Party.state_physics_processing.connect(_on_state_physics_processing_battle_gui_party)
		%StateChart/Battle_GUI/Party.state_exited.connect(_on_state_exited_battle_gui_party)
	
	## Items
	if ui_grid_items:
		ui_grid_items.hide()
		ui_button_items.pressed.connect(_on_button_pressed_items)
		%StateChart/Battle_GUI/Items.state_entered.connect(_on_state_entered_battle_gui_items)
		%StateChart/Battle_GUI/Items.state_physics_processing.connect(_on_state_physics_processing_battle_gui_items)
		%StateChart/Battle_GUI/Items.state_exited.connect(_on_state_exited_battle_gui_items)
	
	## Escape
	ui_button_escape.pressed.connect(_on_button_pressed_escape)
	
	## Skillcheck
	ui_skillcheck.hide()
	Events.skillcheck_hit.connect(_on_skillcheck_hit)
	%StateChart/Battle_GUI/Skillcheck.state_entered.connect(_on_state_entered_battle_gui_skillcheck)
	%StateChart/Battle_GUI/Skillcheck.state_physics_processing.connect(_on_state_physics_processing_battle_gui_skillcheck) #long af
	%StateChart/Battle_GUI/Skillcheck.state_exited.connect(_on_state_exited_battle_gui_skillcheck)
	
	## Global events of entity attack
	Events.battle_entity_attack_start.connect(_on_battle_entity_attack_start)
	Events.battle_entity_attack_end.connect(_on_battle_entity_attack_end)
	
	# Misc
	ui_input_prompt_Q.hide()
	ui_input_prompt_SPACE.hide()
	ui_input_prompt_SPACE_ATTACK.hide()
	ui_input_prompt_SPACE_DEFEND.hide()
	# When enabled
	%StateChart/Battle_GUI.state_input.connect(_on_state_input_battle_gui)
	# 
	ui_description_box.hide()
	ui_panel_menu.hide()
	# Disabled
	%StateChart/Battle_GUI/Disabled.state_entered.connect(_on_state_entered_battle_gui_disabled)
	%StateChart/Battle_GUI/Disabled.state_exited.connect(_on_state_exited_battle_gui_disabled)
	# Select
	%StateChart/Battle_GUI/Select.state_entered.connect(_on_state_entered_battle_gui_select)
	%StateChart/Battle_GUI/Select.state_exited.connect(_on_state_exited_battle_gui_select)
	%StateChart/Battle_GUI/Select.state_physics_processing.connect(_on_state_physics_processing_battle_gui_select)

#TODO add back button for GUIs in state machine?
# on_back and then it points to diff state depending on its current one

## --- Utility Functions ---

func update_selector_position() -> void:
	
	Battle.set_battle_spotlight_target(selected_target)
	
	#selector_sprite.global_position.x = selected_target.animations.selector_anchor.global_position.x
	#selector_sprite.global_position.y = selected_target.animations.selector_anchor.global_position.y
	#selector_sprite.global_position.z = selected_target.animations.selector_anchor.global_position.z

## --- States ----

## Enabled

func _on_state_input_battle_gui(event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_cancel")

## Disabled

func _on_state_entered_battle_gui_disabled() -> void:
	active_portrait.modulate = Color("808080")
	ui_panel_menu.hide()
func _on_state_exited_battle_gui_disabled() -> void:
	ui_panel_menu.show()

## "Main" or Main menu

func _on_state_entered_battle_gui_main() -> void:
	active_portrait.modulate = Color("ffffff")
	ui_panel_menu.show() #Show main panel
	ui_grid_main.show() #Show main grid of buttons
	ui_input_prompt_Q.show()
	
func _on_state_input_battle_gui_main(event : InputEvent) -> void:
	if Input.is_action_just_pressed("interact_secondary"):
			Battle.swap_position_list(0,1,true)
			print("EE")

func _on_state_exited_battle_gui_main() -> void:
	ui_panel_menu.hide() #Hide main panel
	ui_grid_main.hide() #Hide main grid of buttons
	ui_input_prompt_Q.hide()

## Attack

func _on_battle_entity_attack_start(entity : Node) -> void:
	ui_input_prompt_SPACE.show()
	if entity.alignment == Battle.alignment.FRIENDS:
		ui_input_prompt_SPACE_ATTACK.show()
	else:
		ui_input_prompt_SPACE_DEFEND.show()

func _on_battle_entity_attack_end(entity : Node) -> void:
	ui_input_prompt_SPACE.hide()
	if entity.alignment == Battle.alignment.FRIENDS:
		ui_input_prompt_SPACE_ATTACK.hide()
	else:
		ui_input_prompt_SPACE_DEFEND.hide()

func _on_button_pressed_attack() -> void:
	
	var abil = component_ability.ability_tackle.new()
	abil.caster = owner
	
	var properties = {
		"ability" : abil
	}
	_on_button_pressed_echoes_ability(properties)

## Battle

func _on_state_entered_battle_gui_echoes() -> void:
	ui_panel_menu.show() #Show main panel
	ui_grid_echoes.show() #Show battle grid of buttons
	
	#removing old abilities
	for child in ui_grid_echoes.get_children():
			child.queue_free()
	#adding new ones
	for ability in owner.my_component_ability.get_abilities():
		
		var new_button = Glossary.ui.empty_properties_button.instantiate()
		
		new_button.text = str(ability.type.ICON," ",ability.title)
		new_button.properties.ability = ability
		
		##REMOVE
		new_button.properties.description_box = ui_description_box
		new_button.properties.description_label = ui_description_label
		
		## Signals
		new_button.button_pressed_properties.connect(_on_button_pressed_echoes_ability)
		new_button.button_enter_hover_properties.connect(_on_button_enter_hover_battle_ability)
		new_button.button_exit_hover_properties.connect(_on_button_exit_hover_battle_ability)
		
		ui_grid_echoes.add_child(new_button)
		new_button.show()

func _on_state_physics_processing_battle_gui_echoes(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_gui_main")

func _on_state_exited_battle_gui_echoes() -> void:
	ui_panel_menu.hide() #Hide main panel
	ui_grid_echoes.hide() #Hide battle grid of buttons

# Select

func _on_state_entered_battle_gui_select() -> void:
	selected_target = selector_list[0]
	update_selector_position()
	
	ui_input_prompt_SPACE.show()

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
		state_chart.send_event("on_gui_echoes")
	
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

func _on_state_exited_battle_gui_select() -> void:
	selected_target = selector_list[0]
	Battle.set_battle_spotlight_target(owner)
	
	ui_input_prompt_SPACE.hide()

# Skillcheck
## TODO Consider re-adding after playtest? Find a new way to incorporate it

func _on_state_entered_battle_gui_skillcheck() -> void:
	ui_skillcheck_result = "Good"
	state_chart.send_event("on_gui_disabled")
	owner.state_chart.send_event("on_execution")
	
	#ui_skillcheck.show()
	#ui_skillcheck_cursor_anim.speed_scale = owner.my_component_ability.skillcheck_difficulty
	#Battle.set_battle_spotlight_brightness(0)

func _on_state_physics_processing_battle_gui_skillcheck(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_select"):
		ui_skillcheck_cursor_anim.pause()
		
		if ui_skillcheck_cursor.is_colliding():
			ui_skillcheck_result = ui_skillcheck_cursor.get_collider().name
		else:
			ui_skillcheck_result = "Miss"
		
		match ui_skillcheck_result:
			"Miss" : Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("Whoops..."),"text_float_away",Color.SLATE_GRAY)
			"Good" : Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("Nice!"),"text_float_away",Color.SKY_BLUE)
			"Great" : Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("Great!"),"text_float_away",Color.MEDIUM_SLATE_BLUE)
			"Excellent" : Glossary.create_text_particle_queue(owner.animations.selector_anchor,str("Excellent!"),"text_float_away",Color.PURPLE)
		
		await get_tree().create_timer(1.0).timeout

		state_chart.send_event("on_gui_disabled")
		owner.state_chart.send_event("on_execution")

func _on_skillcheck_hit(area,ability_queued) -> void:
	pass

func _on_state_exited_battle_gui_skillcheck() -> void:
	ui_skillcheck.hide()
	ui_skillcheck_cursor_anim.play()
	Battle.reset_battle_spotlight_brightness()

## Switch

func _on_state_entered_battle_gui_party() -> void:
	ui_panel_menu.show()
	ui_grid_party.show()
	
	#removing old dreamkin buttons
	for child in ui_grid_party.get_children():
		child.queue_free()
	#adding new ones
	for i in Global.player.my_component_party.my_party.size(): #TODO Won't work if player is actually dead rn
		
		## Setup
		var dreamkin_inst = Global.player.my_component_party.my_party[i]
		var new_button = Glossary.ui.empty_properties_button.instantiate()
		new_button.text = str(dreamkin_inst.type.ICON," ",dreamkin_inst.name)
		new_button.properties.dreamkin = dreamkin_inst
		
		## Signals
		new_button.button_pressed_properties.connect(_on_button_pressed_party_dreamkin)
		new_button.button_enter_hover_properties.connect(_on_button_enter_hover_party_dreamkin)
		new_button.button_exit_hover_properties.connect(_on_button_exit_hover_party_dreamkin)
		
		## Finalize
		ui_grid_party.add_child(new_button)
		new_button.show()

func _on_state_physics_processing_battle_gui_party(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		state_chart.send_event("on_gui_main")

func _on_state_exited_battle_gui_party() -> void:
	ui_panel_menu.hide()
	ui_grid_party.hide()

## Item

func _on_state_entered_battle_gui_items() -> void:
	ui_panel_menu.show()
	ui_grid_items.show()
	
	Glossary.free_children(ui_grid_items)
	
	var dict = Global.player.my_component_inventory.get_items_from_category(Glossary.item_category.ITEMS.TITLE)
	dict.sort()
	
	var button_list = Glossary.create_button_list(dict,ui_grid_items,self,
	"_on_button_pressed_items_item",
	"_on_button_enter_hover_items_item",
	"_on_button_exit_hover_items_item")
	
	for button in button_list:
		## Display
		if button.properties.item.quantity > 1:
			button.text = str(button.properties.item.title,"  x",button.properties.item.quantity)
		else:
			button.text = button.properties.item.title
	
func _on_state_physics_processing_battle_gui_items(delta: float) -> void:
	pass

func _on_state_exited_battle_gui_items() -> void:
	ui_panel_menu.hide()
	ui_grid_items.hide()

## Escape

func _on_button_pressed_escape() -> void:
	Battle.battle_finalize()

## --- Submenu Buttons ---

## Echoes

func _on_button_pressed_echoes() -> void:
	state_chart.send_event("on_gui_echoes")

func _on_button_pressed_echoes_ability(properties : Dictionary):
	
	var ability = properties.ability

	selector_list = []
	selected_ability = ability
	
	if ability.select_validate():
		selector_list = Battle.get_target_type_list(owner,selected_ability.target_type,true)
		state_chart.send_event("on_gui_select")
	else:
		ability.select_validate_failed()
	
	

func _on_button_enter_hover_battle_ability(properties : Dictionary):
	
	var ability = properties.ability
	
	ui_description_title.text = str(Battle.get_type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",ability.vis_cost," ",Battle.get_type_color_dict(ability.type),ability.type.ICON,"[/color] ",ability.type.TITLE)
	
	ui_description_label.text = str(
		ability.description,"\n",
		"\n",
		Battle.get_type_color("DESCRIPTION"),ability.target_selector.DESCRIPTION,"[/color]","\n",
	)
	ui_description_box.show()

func _on_button_exit_hover_battle_ability(properties : Dictionary):
	ui_description_box.hide()
	ui_description_label.text = ""

## Switch

func _on_button_pressed_party() -> void:
	##Verify we can switch Dreamkin
	#Later this will include a debuff where we can't swap too
	if Global.player.my_component_party.my_party.size() > 0:
		state_chart.send_event("on_gui_party")
	else:
		print_debug("No party members to swap to!")

func _on_button_pressed_party_dreamkin(properties : Dictionary):
	
	var dreamkin = properties.dreamkin
	
	##This event is global, so if you ever have two of it keep that in mind. It won't work for each individually
	
	if dreamkin.select_validate(): #They are eligible to go into battle
		
		var dreamkin_list = Battle.search_classification("DREAMKIN",Battle.alignment.FRIENDS) #Find other Dreamkin in battle on our team
		var new_dreamkin_inst = Global.player.my_component_party.summon(Global.player.my_component_party.my_party.find(dreamkin),"battle") #Find new dreamkin's index, and summon it
		
		if dreamkin_list.size() > 1: #Impossible or bug, should only have 1 active dreamkin
			push_error("ERROR: Detecting >2 Dreamkin on Battlefield - ",dreamkin_list)
		else:
			if dreamkin_list.size() == 1: #There is another active dreamkin
				var old_dreamkin = dreamkin_list[0]
				var old_dreamkin_battle_index = Battle.battle_list.find(old_dreamkin) #Grab the battle index for the old dreamkin we are swapping out	
				Battle.replace_member(new_dreamkin_inst,old_dreamkin_battle_index) #Update battle list to include that new summon
				Global.player.my_component_party.recall(Global.player.my_component_party.my_summons.find(old_dreamkin)) #Find the old dreamkin that was on the field and recall it
			
			else: #No dreamkin on battlefield
				
				if Global.player in Battle.battle_list: #If our player is alive still
					Battle.add_member(new_dreamkin_inst,Battle.battle_list.find(Global.player)+1) #Add us after player
				
				else: #We are the last one (somehow)
					Battle.add_member(new_dreamkin_inst,0)
			
			print_debug("Swapping out Dreamkin...")
			
			state_chart.send_event("on_gui_disabled") #Disable gui
			
			#await new_dreamkin_inst.ready TBD don't need??
			Events.turn_end.emit.call_deferred() #End turn without any phases
			#owner.state_chart.send_event("on_end") #End our turn
	else:
		print(dreamkin.name," is unconscious!")

func _on_button_enter_hover_party_dreamkin(properties : Dictionary):
	var dreamkin = properties.dreamkin
	var abil_list = ""
	
	for ability in dreamkin.my_abilities:
		abil_list += str(Battle.get_type_color_dict(ability.type),ability.type.ICON,"[/color] ",ability.title,
		"\n")
	
	ui_description_title.text = str(
		#Battle.get_type_color_dict(dreamkin.type),dreamkin.type.ICON,"[/color] ",dreamkin.name,"\n",
		Battle.get_type_color("HEALTH"),Battle.type.HEALTH.ICON,"[/color] ",dreamkin.health,"/",dreamkin.max_health,"  ",
		Battle.get_type_color("VIS"),Battle.type.VIS.ICON,"[/color] ",dreamkin.vis,"/",dreamkin.max_vis,"\n",
		abil_list
	)
	
	ui_description_box.show()

func _on_button_exit_hover_party_dreamkin(properties : Dictionary):
	ui_description_box.hide()
	ui_description_label.text = ""

## Item

func _on_button_pressed_items() -> void:
	var item_list = Global.player.my_component_inventory.get_items_from_category(Glossary.item_category.ITEMS.TITLE)
	if item_list.size() > 0:
		state_chart.send_event("on_gui_items")
	else:
		print_debug("No items available to use!")

func _on_button_pressed_items_item(properties : Dictionary):
	Glossary.create_options_list(properties,ui_grid_items,self,"_on_button_pressed_items_option","battle")

func _on_button_enter_hover_items_item(properties : Dictionary):
	
	var item = properties.item
	
	#TBD
	ui_description_title.text = str("meep meep")
	
	ui_description_label.text = str(
		Glossary.text_style_color_html(Glossary.text_style.FLAVOR),item.flavor,"[/color]",
		"\n",
		"\n",
		item.description
		)
		
	ui_description_box.show()

func _on_button_exit_hover_items_item(properties : Dictionary):
	ui_description_box.hide()

func _on_button_pressed_items_option(properties : Dictionary):
	
	var result = Glossary.evaluate_option_properties(properties,ui_grid_items,self,
	"_on_button_pressed_items_option",
	"battle",
	"_on_button_enter_hover_items_option",
	"_on_button_exit_hover_items_option")
	
	if result == Glossary.options_result.FINISHED:
		state_chart.send_event("on_gui_disabled")

func _on_button_enter_hover_items_option(properties : Dictionary):
	if "info" in properties:
		var dict = Glossary.convert_info_universal_gui(properties.info)
		ui_description_label.text = dict.description
		ui_description_box.show()

func _on_button_exit_hover_items_option(properties : Dictionary):
	ui_description_box.hide()
