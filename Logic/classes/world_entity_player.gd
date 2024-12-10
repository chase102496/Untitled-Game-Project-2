class_name world_entity_player
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party
@export var my_component_ability : component_ability
@export var my_component_inventory : component_inventory
@export var my_component_respawn_handler : component_respawn_handler
@export var my_inventory_gui : Control
@export var loomlight : Node3D

func _ready():
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	my_component_ability.my_abilities.append(component_ability.ability_tackle.new(self))
	my_component_ability.my_abilities.append(component_ability.ability_heartstitch.new(self))
	#my_component_ability.my_status.add(my_component_ability.status_fear.new(self))
	
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,2))
	my_component_inventory.add_item(component_inventory.item_nectar.new(self,1,5))
	
	my_component_inventory.add_item(component_inventory.item_dewdrop.new(self,1,1))
	
	#TODO FIX THIS TO RUN POSITION ON A PER-TRANSFER BASIS WHERE THE OLD WORLD -> NEW WORLD, the OLD WORLD tells us where we're spawning in the new one.
	
	#PlayerData.load_data_scene(position of player new spawn)
	#OR, we edit the actual data package on pre-scene transition, in the scenetransition Singleton
	
	#Position should be a scene-based save
	#When we go through a pathway leading from one scene to another, the previous scene dictates where we will spawn in the new scene
		#Can be stored as data.global_position just like we would right before a battle. Then, the other world can handle that data.
		#We can save each entry point in a world as a Vector3 in a Glossary of all world locations
	#When we go from a battle scene to a world scene, the world's position save dictates where we will spawn
		#Can be stored as data.gloval_position right before we enter battle, and is loaded on battle end
		
	#When we leave a scene for whatever reason, the only time we ever need to save our position is if we're entering battle or a cutscene or something, otherwise ignore global pos save
	
	#When we enter a scene for whatever reason, we always need a data point for where to put the player.
	
	#Each scene will have a default global position to load the player. This will be a Vector3 export variable

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
		Battle.battle_initialize("enemy_gloam enemy_gloam")
	if Input.is_action_just_pressed("num1"):
		SceneManager.transition_to("res://Levels/hotus_house.tscn")
	if Input.is_action_just_pressed("num2"):
		SceneManager.transition_to("res://Levels/dream_garden.tscn")
		#TODO make instance version of initialize similar to ability and status where we determine all the junk at creation not just a name
