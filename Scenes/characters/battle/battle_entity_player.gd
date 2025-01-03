class_name battle_entity_player_new
extends battle_entity

@export_group("Modules")
@export var my_battle_gui : battle_gui

@export_group("Components")
@export var my_component_party : component_party
@export var my_component_inventory : component_inventory

#func _init() -> void:
	#Global.player = self

func _ready():
	Global.player = self

func on_save(all_data):
	
	var key = SaveManager.get_save_id_global(self,all_data,"player")
	var data = all_data[key]
	
	##Player
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

func on_load(all_data):
	
	var key = SaveManager.get_save_id_global(self,all_data,"player")
	var data = all_data[key]
	
	##Player
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
	var inst = my_component_party.summon(0,"battle") #Summon top of the list
	if inst: #If our instance exists
		Battle.add_member.call_deferred(inst,1) #Add to battle list
	##Inventory
	my_component_inventory.set_data_inventory_all(self,data.my_inventory)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		Debug.toggle()
