class_name component_party
extends Node

var party : Array = []

func get_party():
	if party.size() > 0:
		return party
	else:
		return null

func set_primary(entity : Node):
	if party.find(entity) != -1: #If it's already in the array
		party.pop_at(party.find(entity))
	
	party.push_front(entity)

func get_primary():
	return party[0]

func add(entity : Node):
	party.append(entity)

func remove(entity : Node):
	#Validation
	party.pop_at(party.find(entity))
