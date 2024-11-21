class_name component_party
extends Node

var my_party : Array = []

var summon : Node = null

  #TODO ALL OF THIS IS IN PROGRESS

func update_party():
	for i in my_party.size():
		if i == 0:
			my_party[i].process_mode = PROCESS_MODE_INHERIT
			my_party[i].state_chart.send_event.call_deferred("on_idle")
			my_party[i].show()
		else:
			my_party[i].process_mode = PROCESS_MODE_DISABLED
			my_party[i].state_chart.send_event.call_deferred("on_pause_input")
			my_party[i].hide()

func get_party():
	if my_party.size() > 0:
		return my_party
	else:
		return null

func set_party(party : Array):
	for i in my_party.size():
		my_party[i].queue_free()
	my_party = party
	update_party()

func get_primary():
	if my_party.size() > 0:
		return my_party[0]
	else:
		return null

func set_primary(entity : Node): #this one will swap out in combat and world
	if my_party.find(entity) == -1:
		push_error("ERROR: No entity found for set_primary - ",entity)
	elif !get_party():
		push_error("ERROR: No entities found in party")
	else:
		my_party.pop_at(my_party.find(entity))
		my_party.push_front(entity)
		update_party()

func add_party(entity : Node):
	my_party.append(entity)
	update_party()

func remove_party(entity : Node):
	my_party.pop_at(my_party.find(entity))
	update_party()
