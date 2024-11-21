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
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Events.battle_finished.emit("Win")

func on_save(data):
	pass
	
func on_load(data):
	pass

func on_load_data_scene():
	pass
	
func on_save_data_scene():
	pass
	
