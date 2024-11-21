class_name battle_entity_player
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control

@export_group("Components")
@export var my_component_party : component_party
#@export var my_component_input_controller : Node

func _ready():
	#name = str(name," ",randi())
	#abil.my_abilities.append(abil.ability_switchstitch.new(self))
	#abil.my_abilities.append(abil.ability_frigid_core.new(self,1,1))
	
	#PlayerData.load_data()
	
	#my_component_party.add( 
	PlayerData.load_data_scene()
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Events.battle_finished.emit("Win")

func on_save(data):
	print_debug("+ Saved data: ",data)
	##Player
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
	#global_position = data.global_position
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	##Abilities
	my_component_ability.set_data_all(self,data.my_abilities)
	
	##Dreamkin
	var inst_list : Array = []
	for i in data.my_party.size():
		var unit_data = data.my_party[i]
		#Make sure it's under our 'Friends' node, in initial state of waiting for turn, and prefix = battle!
		var inst = Glossary.find_entity(unit_data.glossary,"battle").instantiate().init(get_parent(),global_position,"on_waiting") 
		inst.my_component_health.set_deferred("health",unit_data.health)
		inst.my_component_health.set_deferred("max_health",unit_data.max_health)
		inst.my_component_vis.set_deferred("vis",unit_data.vis)
		inst.my_component_vis.set_deferred("max_vis",unit_data.max_vis)
		##Abilities
		inst.my_component_ability.set_data_all.call_deferred(inst,unit_data.my_abilities)
		inst_list.append(inst)
		
		if i == 0:
			Battle.add_member(inst,1)
	
	my_component_party.set_party(inst_list)

func on_save_data_scene():
	on_save(PlayerData.data_scene.player)

func on_load_data_scene():
	on_load(PlayerData.data_scene.player)
	
