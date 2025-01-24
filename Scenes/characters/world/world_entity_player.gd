class_name world_entity_player
extends world_entity

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party
@export var my_component_ability : component_ability
@export var my_component_inventory : component_inventory
@export var my_component_world_ability : component_world_ability
@export var my_component_interaction : component_interaction
@export var my_world_gui : Control
@export var gloam_manager : component_gloam_manager
@export var my_vignette : Control

func _ready():
	icon = Glossary.icon_scene["lumia"]
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	
	##HACK ALL THIS GETS OVERWRITTEN IF WE LOAD A SAVE
	my_component_ability.add_ability(component_ability.ability_soulstitch.new())
	my_component_ability.add_ability(component_ability.ability_switchstitch.new())
	my_component_ability.add_ability(component_ability.ability_spook.new())
	my_component_ability.add_ability(component_ability.ability_frigid_core.new())
	
	my_component_inventory.add_item(component_inventory.item_echo.new(self,"world_ability_loomlight"))
	my_component_inventory.add_item(component_inventory.item_echo.new(self,"world_ability_soulstitch"))
	
	#
	
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,2))
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,5))
	
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))
	
	##Debug
	if my_component_party.my_party.size() == 0:
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 100},get_parent()),false)
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 99},get_parent()),false)
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 98},get_parent()),false)

func on_save(all_data):
	
	var key = SaveManager.get_save_id_global(self,all_data,"player")
	var data = all_data[key]
	
	data.scene_name = SceneManager.current_scene.name
	data.collision_mask = collision_mask
	data.collision_layer = collision_layer
	data.global_position = global_position
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	## Inventory
	data.my_inventory = my_component_inventory.get_data_inventory_all()
	## World Ability we had active
	data.my_active_ability = my_component_world_ability.active
	## Abilities & World Abilities
	data.my_abilities = my_component_ability.get_data_ability_all()
	## Status fx
	data.my_status = my_component_ability.get_data_status_all()
	## Dreamkin
	data.my_party = my_component_party.export_party()
	

func on_load(all_data):
	
	var key = SaveManager.get_save_id_global(self,all_data,"player")
	var data = all_data[key]
	
	##Player
	#If we're loading the same exact scene as our save file, then we want to also load our position.
	#It's either after exiting battle, or loading a save file from title screen
	if SceneManager.current_scene.name == data.scene_name:
		global_position = data.global_position
	#If we're loading a scene that our save file was not in
	#It's either after changing scenes, or some other edge case
	else:
		pass #This is where we recieve global pos info from old world saved in a global var

	collision_mask = data.collision_mask
	collision_layer = data.collision_layer
	
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	##Inventory
	my_component_inventory.set_data_inventory_all(self,data.my_inventory)
	##World Abilities
	for item in my_component_inventory.get_items_from_category(Glossary.item_category.GEAR.TITLE):
		if item.is_equipped:
			my_component_world_ability.set_equipment(item.my_world_ability)
	##Abilities
	my_component_ability.set_data_ability_all(self,data.my_abilities)
	##Status fx
	my_component_ability.set_data_status_all(self,data.my_status)
	##Dreamkin
	my_component_party.import_party(data.my_party)

func _input(event: InputEvent) -> void:
	
	#if Input.is_action_just_pressed("move_forward"):
		##if my_component_party.get_party():
			##for i in my_component_party.get_party().size():
				##my_component_party.my_party[i].my_component_health.change(-1)
		#my_component_party.recall(0)
#
	#if Input.is_action_just_pressed("move_backward"):
		#my_component_party.summon(0,"world")
		#
	#if Input.is_action_just_pressed("move_jump"):
		#my_component_party.add_summon_dreamkin(Glossary.get_entity("world_entity_dreamkin_default").instantiate().init(
			#owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
			#)
	
	if Input.is_action_just_pressed("debug"):
		Debug.toggle()
	
	if Input.is_action_just_pressed("save"):
		SaveManager.save_data_persistent() #HACK
	if Input.is_action_just_pressed("load"):
		SaveManager.load_data_persistent() #HACK
	if Input.is_action_just_pressed("clear_save"):
		SaveManager.reset_data_persistent()
	
	#if Input.is_action_just_pressed("num1"):
		#if my_component_party.my_summons.size() > 0:
			#my_component_party.my_summons[0].animations.import_visual_set(Glossary.visual_set["axolotl_red"])
	
	if Input.is_action_just_pressed("num0"):
		#Battle.encounter["gloam_trio"].call()
		#Battle.battle_initialize("enemy enemy")
		
		var encounter_pool : Array = [
		{
			"weight" : 0.5,
			"result" : Glossary.encounter["gloamling_trio"]
		},
		{
			"weight" : 0.5,
			"result" : Glossary.encounter["gloamling_duo"]
		},
		]
		
		Battle.battle_initialize_verbose(Global.pick_weighted(encounter_pool))
		#var test = my_component_ability.add_ability(component_ability.ability_spook.new())
		pass
	
	#if Input.is_action_just_pressed("num2"):
		#SceneManager.transition_to("res://Levels/dream_garden.tscn")
		#TODO make instance version of initialize similar to ability and status where we determine all the junk at creation not just a name
