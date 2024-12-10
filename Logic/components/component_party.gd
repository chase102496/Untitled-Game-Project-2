class_name component_party
extends Node

var my_summons : Array = [] #Our actual party members summoned currently
var my_party : Array = [] #The reference data of all our party members

var default_world_summon : int #The unique_id of your favorited dreamkin for summoning in the world
var default_battle_summon : int #The unique_id of your favorited dreamkin for summoning in battle

##Class framework that holds dreamkin data. Saved as a class so we can still manipulate it in our party with custom functions
class party_dreamkin:
	extends Object
	
	#Some typing to make sure data isn't wonky
	var name : String
	var classification : String
	var unique_id : int
	var global_position : Vector3
	var glossary : String
	var type : Dictionary
	var health : int
	var max_health : int
	var vis : int
	var max_vis : int
	var my_abilities : Array
	var my_status : Dictionary
	var options_world : Dictionary = {}
	var options_battle : Dictionary = {}
	
	## Sets whatever is in the dictionary directly to US
	func _init(data : Dictionary) -> void:
		for i in data.size():
			var key = data.keys()[i]
			var value = data.values()[i]
			self.set(key,value)
		
		## Options when selected in inventory
		options_world = {
			"Summon" : Callable(self,"summon_world"),
		}
	
	func summon_world():
		Global.player.my_component_party.recall_all()
		var my_index = Global.player.my_component_party.my_party.find(self)
		Global.player.my_component_party.summon(my_index,"world")
		Global.player.my_inventory_gui.refresh()
	
	##Export just our variable as a single dictionary
	func get_dreamkin_data_dictionary():
		var my_script = get_script()
		var data : Dictionary = {}
		
		for i in my_script.get_script_property_list():
			var property_name: String = i.name
			var property_value = get(property_name)
			data[property_name] = property_value
		
		return data
	
	func select_validate():
		if health > 0:
			return true
		else:
			return false
	
	func change_health(amt : int):
		health = clamp(health + amt,0,max_health)
	
	func change_vis(amt : int):
		vis = clamp(vis - amt,0,max_vis)
		
## --- Getters ---

##Get obj data from active summon list
func get_summon_data(index : int):
	var summon_inst = my_summons[index] #Grab the summon member
	var dreamkin_summon_data = summon_inst.get_dreamkin_data_dictionary() #Ask for Dictionary
	return dreamkin_summon_data #Return the Dictionary

##Get obj data from party member list
func get_party_data(index : int):
	var party_inst = my_party[index] #Grab the party member
	var dreamkin_party_data = party_inst.get_dreamkin_data_dictionary() #Ask for Dictionary
	return dreamkin_party_data #Return the Dictionary

##Get data with both summons and party members stuffed into one array
func get_hybrid_data_all():
	return my_summons + my_party

##Returns the names of all Dreamkin summoned and in party as strings in array
func get_hybrid_name_all():
	var result : Array = []
	for summon_inst in my_summons:
		result.append(summon_inst.name)
	for party_inst in my_party:
		result.append(party_inst.name)
	return result

##Gets the results of any dreamkin anywhere in our summons or party based on a unique identifier
func get_dreamkin_unique(unique_id : int):
	for dreamkin in get_hybrid_data_all():
		if dreamkin.unique_id == unique_id:
			return dreamkin
	return null

##Get read-only data from any dreamkin, summon or party, and convert to dreamkin party object if not already
##Can also convert orphan dreamkin that aren't in our party
##Basically just converts anything you pull into party data, so you can read it consistently
##NOT used to manipulate data, just to read it
func get_universal_data(dreamkin):
	if dreamkin is Node:
		return party_dreamkin.new(dreamkin.get_dreamkin_data_dictionary())
	elif dreamkin is Object:
		return dreamkin
	else:
		push_error("Could not convert dreamkin to party object - ",dreamkin)

## --- Manipulation ---

##Adds a dreamkin to our party based on dreamkin object data
func add_data_dreamkin(data : Dictionary):#, summoned : bool = false):
	my_party.append(party_dreamkin.new(data))

##Adds a dreamkin to our party based on a dreamkin object
func add_party_dreamkin(obj : Object):#, summoned : bool = false):
	my_party.append(obj)

##Adds a dreamkin to our party or summons based on an in-world instance
#Maybe later make auto detection for world type to determine if battle or world?
func add_summon_dreamkin(instance : Node, summoned : bool = true):

	my_summons.append(instance)
	
	##Recall our dreamkin to its object form
	if !summoned:
		await instance.ready
		recall(my_summons.find(instance))

## --- Main Methods ---

##Load party to a summon
#maybe later have this take a dreamkin object to unpack instead of index
func summon(index : int, battle_or_world : String):
	if index < my_party.size():
		var party_inst = my_party[index] #Grab the right party member
		if party_inst.select_validate():
			var summon_inst = Glossary.find_entity(party_inst.glossary,battle_or_world).instantiate().party_summon(party_inst)
			##Add to my_summons, remove from my_party
			my_summons.append(summon_inst)
			my_party.pop_at(index)
			return summon_inst
		else:
			print_debug(party_inst.name, " is unconscious!")
	else:
		print_debug("No party members available to summon!")

##Load party to a summon, but with an object ref instead of index
func summon_inst(dreamkin : Object, battle_or_world : String):
	var index = my_summons.find(dreamkin)
	summon(index,battle_or_world)

##Load party to a summon, and recall all other dreamkin if they exist
func summon_and_recall(dreamkin : Object, battle_or_world : String):
	recall_all()
	summon_inst(dreamkin,battle_or_world)

func summon_all(battle_or_world : String):
	for i in my_summons.size():
		summon(i,battle_or_world)

##Save summon to our party
func recall(index : int):
	if index < my_summons.size() and index >= 0:
		##Get data for active summon at index
		var party_data = get_summon_data(index)
		##Convert data to object to put into party
		var party_inst = party_dreamkin.new(party_data)
		##Add to party, remove from summons
		my_party.push_front(party_inst)
		##Pop old summon out of my_summons and delete instance
		var summon_inst = my_summons.pop_at(index)
		summon_inst.queue_free()
		return party_inst #Return the new party dreamkin object
	else:
		print_debug("Could not recall #",index," out of bounds ",my_party)

##Save summon to our party, instance instead of index
func recall_inst(dreamkin : Node):
	var index = my_summons.find(dreamkin)
	recall(index)

func recall_all():
	for i in my_summons.size():
		recall(i)

##Export all of our dreamkin into an array of dictionaries
func export_party():
	var result : Array = []
	for i in my_summons.size(): #Convert all summons to data blocks
		var data_summon = get_summon_data(my_summons.find(my_summons[i]))
		result.append(data_summon)
	for i in my_party.size(): #Convert all party members to data blocks
		var data_party = get_party_data(my_party.find(my_party[i]))
		result.append(data_party)
	return result

##Import a new party from a data file
func import_party(data_list : Array):
	##Clear both rosters
	my_party.clear()
	for i in my_summons.size():
		my_summons[i].queue_free()
	my_summons.clear()
	
	#Load new data as party (no summons yet)
	for i in data_list.size():
		var inst = party_dreamkin.new(data_list[i])
		my_party.append(inst)
