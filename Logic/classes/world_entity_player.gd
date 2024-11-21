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
	my_component_ability.my_abilities.append(component_ability.ability_tackle.new(self))
	#abil.my_abilities.append(abil.ability_heartstitch.new(self))
	PlayerData.load_data_scene()

func on_save(data):
	print_debug("+ Saved data: ",data)
	##Player
	data.global_position = global_position
	data.health = my_component_health.health
	data.max_health = my_component_health.max_health
	data.vis = my_component_vis.vis
	data.max_vis = my_component_vis.max_vis
	##Player abilities
	data.my_abilities = my_component_ability.get_data_all()
	
	##Dreamkin
	##If no data has been made, make an array
	if !data.get("my_party"):
		data.my_party = []
	for i in my_component_party.my_party.size():
		var unit = my_component_party.my_party[i]
		
		##Ensures we don't get missing indicies
		if data.my_party.size() < i+1:
			data.my_party.append({})
		
		data.my_party[i].global_position = unit.global_position
		data.my_party[i].glossary = unit.glossary
		data.my_party[i].health = unit.my_component_health.health
		data.my_party[i].max_health = unit.my_component_health.max_health
		data.my_party[i].vis = unit.my_component_vis.vis
		data.my_party[i].max_vis = unit.my_component_vis.max_vis
		
		##Dreamkin abilities
		data.my_party[i].my_abilities = unit.my_component_ability.get_data_all()

func on_load(data):
	print_debug("+ Loaded data: ",data)
	##Player
	global_position = data.global_position
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	##Abilities
	my_component_ability.set_data_all(self,data.my_abilities)
	
	##Dreamkin
	var inst_list : Array = []
	for i in data.my_party.size():
		
		print("+++++++++",data.my_party[i]["global_position"])
		
		var unit_data = data.my_party[i]
		var inst = Glossary.find_entity(unit_data.glossary,"world").instantiate().init(get_parent(),unit_data.global_position)
		inst.my_component_health.set_deferred("health",unit_data.health)
		inst.my_component_health.set_deferred("max_health",unit_data.max_health)
		inst.my_component_vis.set_deferred("vis",unit_data.vis)
		inst.my_component_vis.set_deferred("max_vis",unit_data.max_vis)
		##Abilities
		inst.my_component_ability.set_data_all.call_deferred(inst,unit_data.my_abilities)
		inst_list.append(inst)
	
	my_component_party.set_party(inst_list)

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
		#Callable(NORMAL,event).callv(args)
		
		#var test = my_component_ability.get_data_all()#[0]["id"]
		
		#print(glossary)
		
		#my_component_ability.my_abilities[0].damage += 10
		
		#my_component_ability.my_abilities.append(component_ability.ability_spook.new(self,3,0.5,2))
		
		#var test = my_component_party.my_party[0].test.instantiate()
		#add_child(test)
		#test.global_position = global_position
		#print(test[0]["id"].new(owner,1).get_data())
		#
		#Callable("world_entity_dreamkin_default","create")
		#print(my_component_ability.my_abilities[0].get_data())
		#print(self.get_global_name())
		pass
		
	if Input.is_action_just_pressed("move_jump"):
		my_component_party.add_party(#global_position+Vector3(randf_range(0,2),0,randf_range(0,2))
			Glossary.find_entity("world_entity_dreamkin_default").instantiate().init(owner,global_position+Vector3(randf_range(0,2),0,randf_range(0,2)))
			)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize("enemy_gloam enemy_gloam enemy_gloam")
