class_name world_entity_player
extends world_entity_default

@export_group("Components")
@export var my_component_movement_controller: component_movement_controller
@export var my_component_input_controller: component_input_controller_manual
@export var my_component_party : component_party
@export var my_component_ability : component_ability

func _ready():
	#name = str(name," ",randi())
	Global.player = self
	Dialogic.preload_timeline("res://timeline.dtl")
	

func on_save(data):
	print_debug("+ Saved to ",data)
	##Player
	data.global_position = global_position
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	data.my_abilities = my_component_ability.my_abilities
	
	data.my_party = []
	##Dreamkin
	for i in my_component_party.my_party.size():
		var unit = my_component_party.my_party[i]
		data.my_party.append({
			"glossary" : unit.glossary,
			"global_position" : unit.global_position,
			"health" : unit.my_component_health.health,
			"max_health" : unit.my_component_health.max_health,
			"vis" : unit.my_component_vis.vis,
			"max_vis" : unit.my_component_vis.max_vis,
			"my_abilities" : unit.my_component_ability.my_abilities
		})

func on_load(data):
	print_debug("+ Loaded from ",data)
	##Player
	global_position = data.global_position
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	my_component_ability.my_abilities = data.my_abilities
	
	##Dreamkin
	for i in data.my_party.size():
		var unit_data = data.my_party[i]
		var inst = Glossary.world_entity_class[unit_data.glossary].create(unit_data.global_position,owner)
		inst.my_component_health.set_deferred("health",unit_data.health)
		inst.my_component_health.set_deferred("max_health",unit_data.max_health)
		inst.my_component_vis.set_deferred("vis",unit_data.vis)
		inst.my_component_vis.set_deferred("max_vis",unit_data.max_vis)
		inst.my_component_ability.set_deferred("my_abilities",unit_data.my_abilities)

		my_component_party.add(inst)

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
		if my_component_party.get_party():
			my_component_party.my_party[0].my_component_health.damage(1)

	if Input.is_action_just_pressed("move_backward"):
		if my_component_party.get_party():
			if my_component_party.my_party[0].is_inside_tree():
				my_component_party.my_party[0]
			else:
				my_component_party.my_party[0].process_mode = PROCESS_MODE_DISABLED
	
	if Input.is_action_just_pressed("move_jump"):
		my_component_party.add(
			Glossary.world_entity_class["entity_dreamkin_default"].create(global_position+Vector3(randf_range(0,2),0,randf_range(0,2)),owner)
			)
			
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize("enemy_gloam enemy_gloam enemy_gloam")
