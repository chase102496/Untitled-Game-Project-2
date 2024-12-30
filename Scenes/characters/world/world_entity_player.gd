class_name world_entity_player
extends world_entity

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party
@export var my_component_ability : component_ability
@export var my_component_inventory : component_inventory
@export var my_component_respawn_handler : component_respawn_handler
@export var my_component_equipment : component_equipment
@export var my_component_interaction : component_interaction
@export var my_inventory_gui : Control
@export var gloam_manager : component_gloam_manager
@export var my_vignette : Control

func _ready():
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	my_component_ability.add_ability(component_ability.ability_tackle.new())
	my_component_ability.add_ability(component_ability.ability_heartlink.new())
	
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,2))
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,5))
	
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))

	PlayerData.load_data_session()
	
	##Debug
	if my_component_party.my_party.size() == 0:
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 100},get_parent()),false)
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 99},get_parent()),false)
		my_component_party.add_summon_dreamkin(Entity.new().create("world_entity_dreamkin",{"my_component_health.health" : 98},get_parent()),false)

func on_save(data):
	##Player
	
	if !data.get("collision_mask"):
		data.collision_mask = {}
	if !data.get("collision_layer"):
		data.collision_layer = {}
	
	data.scene_name = SceneManager.current_scene.name
	data.collision_mask[4] = get_collision_mask_value(4)
	data.collision_layer[4] = get_collision_layer_value(4)
	data.global_position = global_position
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	##Abilities
	data.my_abilities = my_component_ability.get_data_ability_all()
	##Status fx
	data.my_status = my_component_ability.get_data_status_all()
	##Dreamkin
	data.my_party = my_component_party.export_party()
	##Inventory
	data.my_inventory = my_component_inventory.get_data_inventory_all()

func on_load(data):
	##Player
	#If we're loading the same exact scene, then we want to also load our position.
	#It's either after exiting battle, or loading a save file from title screen
	if SceneManager.current_scene.name == data.scene_name:
		global_position = data.global_position
	else:
		pass #This is where we recieve global pos info from old world saved in a global var
	
	if data.collision_layer:
		if data.collision_layer[4]:
			set_collision_layer_value(4,data.collision_layer[4])
	if data.collision_mask:
		if data.collision_mask[4]:
			set_collision_mask_value(4,data.collision_mask[4])
	
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	##Abilities
	my_component_ability.set_data_ability_all(self,data.my_abilities)
	##Status fx
	my_component_ability.set_data_status_all(self,data.my_status)
	##Dreamkin
	my_component_party.import_party(data.my_party)
	##Inventory
	my_component_inventory.set_data_inventory_all(self,data.my_inventory)

func on_save_data_session():
	on_save(PlayerData.data_session.player)

func on_load_data_session():
	on_load(PlayerData.data_session.player)

func save_data_persistent():
	on_save(PlayerData.data_persistent.player)

func on_load_data_persistent():
	on_load(PlayerData.data_persistent.player)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		#my_component_party.recall(0)
		PlayerData.save_data_persistent()
	if Input.is_action_just_pressed("load"):
		#my_component_party.summon(0,"world")
		PlayerData.load_data_persistent()
	
	
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
		#my_component_party.add_summon_dreamkin(Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(
			#owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
			#)
	#
	
	if Input.is_action_just_pressed("num1"):
		if my_component_party.my_summons.size() > 0:
			my_component_party.my_summons[0].animations.import_visual_set(Glossary.visual_set["axolotl_red"])
	
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
		
		Battle.battle_initialize_verbose(Glossary.pick_weighted(encounter_pool))
		#var test = my_component_ability.add_ability(component_ability.ability_spook.new())
		pass
	
	#if Input.is_action_just_pressed("num2"):
		#SceneManager.transition_to("res://Levels/dream_garden.tscn")
		#TODO make instance version of initialize similar to ability and status where we determine all the junk at creation not just a name
