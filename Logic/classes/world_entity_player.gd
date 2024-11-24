class_name world_entity_player
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party
@export var my_component_ability : component_ability

func _ready():
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	my_component_ability.my_abilities.append(component_ability.ability_tackle.new(self))
	my_component_ability.my_abilities.append(component_ability.ability_heartstitch.new(self))
	#my_component_ability.current_status_effects.add(my_component_ability.status_fear.new(self))
	PlayerData.load_data_scene()

func on_save(data):
	##Player
	data.global_position = global_position
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	##Abilities
	data.my_abilities = my_component_ability.get_data_ability_all()
	##Status fx
	data.current_status_effects = my_component_ability.get_data_status_all()
	##Dreamkin
	data.my_party = my_component_party.export_party()

func on_load(data):
	##Player
	global_position = data.global_position
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	##Abilities
	my_component_ability.set_data_ability_all(self,data.my_abilities)
	##Status fx
	my_component_ability.set_data_status_all(self,data.current_status_effects)
	##Dreamkin
	my_component_party.import_party(data.my_party)

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
		PlayerData.save_data_all()
	if Input.is_action_just_pressed("load"):
		PlayerData.load_data_all()
	
	if Input.is_action_just_pressed("move_forward"):
		#if my_component_party.get_party():
			#for i in my_component_party.get_party().size():
				#my_component_party.my_party[i].my_component_health.damage(1)
		my_component_party.recall(0)

	if Input.is_action_just_pressed("move_backward"):
		my_component_party.summon(0,"world")
		
	if Input.is_action_just_pressed("move_jump"):
		my_component_party.add_summon_dreamkin(Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(
			owner,global_position+Vector3(randf_range(0.5,1),0,randf_range(0.5,1)))
			)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize("enemy_gloam enemy_gloam")
		#TODO make instance version of initialize similar to ability and status where we determine all the junk at creation not just a name
