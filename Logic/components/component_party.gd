class_name component_party
extends Node

var my_party : Array = []

var summon : Node = null

  #TODO ALL OF THIS IS IN PROGRESS

func get_party():
	if my_party.size() > 0:
		return my_party
	else:
		return null

func world_summon_primary():
	if get_party():
		summon = Glossary.world_entity_class[my_party[0].glossary].create(owner.global_position+Vector3(randf_range(0,2),0,randf_range(0,2)),owner)
	else:
		push_error("No summonable primary entity found")

func world_recall_primary():
	if get_party():
		pass
		#set the vars of the world summon to our
	else:
		push_error("No recallable primary entity found")

func set_primary(entity : Object): #this one will swap out in combat and world
	if my_party.find(entity) == -1:
		push_error("ERROR: No entity found for set_primary - ",entity)
	elif !get_party():
		push_error("ERROR: No entities found in party")
	else:
		my_party.pop_at(my_party.find(entity))
		my_party.push_front(entity)

func get_primary():
	if my_party.size() > 0:
		return my_party[0]
	else:
		return null

func add(entity : Object):
	my_party.append(entity)

func remove(entity : Object):
	my_party.pop_at(my_party.find(entity))
