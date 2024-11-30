class_name component_party
extends Node

var my_summons : Array = [] #Our actual party members summoned currently
var my_party : Array = [] #The reference data of all our party members

##Class framework that holds dreamkin data. Saved as a class so we can still manipulate it in our party with custom functions
class party_dreamkin:
	extends Object
	
	#Some typing to make sure data isn't wonky
	var name : String
	var global_position : Vector3
	var glossary : String
	var type : Dictionary
	var health : int
	var max_health : int
	var vis : int
	var max_vis : int
	var my_abilities : Array
	var current_status_effects : Dictionary
	
	##Sets whatever is in the dictionary directly to US
	func _init(data : Dictionary) -> void:
		for i in data.size():
			var key = data.keys()[i]
			var value = data.values()[i]
			self.set(key,value)
	
	func select_validate():
		if health > 0:
			return true
		else:
			print_debug("Unable to summon, fainted!")
			return false
	
	##Export just our variable as a single dictionary
	func get_dreamkin_data_dictionary():
		var my_script = get_script()
		var data : Dictionary = {}
		
		for i in my_script.get_script_property_list():
			var property_name: String = i.name
			var property_value = get(property_name)
			data[property_name] = property_value
		
		return data

## --- Getters ---

##Get data from active summon
func get_summon_data(index : int):
	var summon_inst = my_summons[index] #Grab the summon member
	var dreamkin_summon_data = summon_inst.get_dreamkin_data_dictionary() #Ask for Dictionary
	return dreamkin_summon_data #Return the Dictionary

##Get data from party member
func get_party_data(index : int):
	var party_inst = my_party[index] #Grab the party member
	var dreamkin_party_data = party_inst.get_dreamkin_data_dictionary() #Ask for Dictionary
	return dreamkin_party_data #Return the Dictionary

##Returns a combination of summoned dreamkin + party dreamkin together in one array. Used for updating live data usually
func get_hybrid_data_all():
	var result : Array = []
	result += my_summons
	result += my_party
	return result

#func get_hybrid_data(index : int):
	#return get_hybrid_data_all()[index]
#
#func set_hybrid_data(index : int):
	#get_hybrid_data_all()[index]

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
		recall(my_summons.find(instance))

## --- Main Methods ---

##Load party to a summon
#maybe later have this take a dreamkin object to unpack instead of index
func summon(index : int, battle_or_world : String):
	if index < my_party.size():
		var party_inst = my_party[index] #Grab the right party member
		var summon_inst = Glossary.find_entity(party_inst.glossary,battle_or_world).instantiate().party_summon(party_inst)
		##Add to my_summons, remove from my_party
		my_summons.append(summon_inst)
		my_party.pop_at(index)
		return summon_inst
	else:
		print_debug("No party members available to summon!")

##Save summon to our party
func recall(index : int):
	if index < my_summons.size():
		##Get data for active summon at index
		var party_data = get_summon_data(index)
		##Convert data to object to put into party
		var party_inst = party_dreamkin.new(party_data)
		##Add to party, remove from summons
		my_party.append(party_inst)
		##Pop old summon out of my_summons and delete instance
		var summon_inst = my_summons.pop_at(index)
		summon_inst.queue_free()
		return party_inst #Return the new party dreamkin object
	else:
		print_debug("No party members available to recall!")

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
