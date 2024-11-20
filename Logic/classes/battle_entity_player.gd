class_name battle_entity_player
extends battle_entity_default

@export_group("Modules")
@export var my_battle_gui : Control

@export_group("Components")
@export var my_component_party : component_party
#@export var my_component_input_controller : Node

func _ready():
	#name = str(name," ",randi())
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.my_abilities.append(abil.ability_heartstitch.new(self))
	#abil.my_abilities.append(abil.ability_switchstitch.new(self))
	#abil.my_abilities.append(abil.ability_frigid_core.new(self,1,1))
	
	#PlayerData.load_data()
	
	#my_component_party.add( 

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Events.battle_finished.emit("Win")

func on_save(data):
	pass
	
func on_load(data):
	print_debug("+ Loaded from ",data)
	##Player
	my_component_health.health = data.health
	my_component_health.max_health = data.max_health
	my_component_vis.vis = data.vis
	my_component_vis.max_vis = data.max_vis
	my_component_ability.my_abilities = data.my_abilities
	
	##Dreamkin
	for i in data.my_party.size():
		var unit_data = data.my_party[i]
		var inst = Glossary.battle_entity_class[unit_data.glossary].create(owner)
		inst.my_component_health.set_deferred("health",unit_data.health)
		inst.my_component_health.set_deferred("max_health",unit_data.max_health)
		inst.my_component_vis.set_deferred("vis",unit_data.vis)
		inst.my_component_vis.set_deferred("max_vis",unit_data.max_vis)
		inst.my_component_ability.set_deferred("my_abilities",unit_data.my_abilities)

		my_component_party.add(inst)

func on_load_data_scene():
	on_load(PlayerData.data_scene) #TODO WIP ALL OF THIS
	
func on_save_data_scene():
	pass
	
