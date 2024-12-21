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
@export var gloam_manager : Node3D

func _ready():
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	my_component_ability.my_abilities.append(component_ability.ability_tackle.new(self))
	my_component_ability.my_abilities.append(component_ability.ability_heartlink.new(self))
	
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,2))
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,5))
	
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))

	PlayerData.load_data_scene()
	
	##Debug
	if my_component_party.my_party.size() == 0:
		my_component_party.add_summon_dreamkin(Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(
				owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
				,false)
		my_component_party.add_summon_dreamkin(Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(
				owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
				,false)
		my_component_party.add_summon_dreamkin(Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(
				owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
				,false)

func on_save(data):
	##Player
	data.scene_name = SceneManager.current_scene.name
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

func on_save_data_scene():
	on_save(PlayerData.data_scene.player)

func on_load_data_scene():
	on_load(PlayerData.data_scene.player)

func on_save_data_all():
	on_save(PlayerData.data_all.player)

func on_load_data_all():
	on_load(PlayerData.data_all.player)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		#my_component_party.recall(0)
		PlayerData.save_data_all()
	if Input.is_action_just_pressed("load"):
		#my_component_party.summon(0,"world")
		PlayerData.load_data_all()
	
	
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
	if Input.is_action_just_pressed("num0"):
		#Battle.encounter["gloam_trio"].call()
		Glossary.deserialize_data(self,{
			"my_component_ability.my_abilities" : [
				component_ability.ability_solar_flare.new(self)
			]
		})
		Battle.battle_initialize("enemy enemy")
		#var test = my_component_ability.add_ability(component_ability.ability_spook.new(self))
		
		pass
	
	#if Input.is_action_just_pressed("num2"):
		#SceneManager.transition_to("res://Levels/dream_garden.tscn")
		#TODO make instance version of initialize similar to ability and status where we determine all the junk at creation not just a name
