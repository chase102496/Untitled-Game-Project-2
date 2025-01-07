## Attach this to any node to give it capability be interactable with the player.
# Use disconnecting/connecting the signals to this component to determine when it's interactable
# Player determines general behavior for interaction to happen, the component just listens

## How-to
# Drag this onto any entity
# Set export val to owner and point to this in host to connect to signals
# Enable global GROUPS so it is detectable by other relevant objects
# Set actions for doing stuff in callables
# ATTACH > EXPORT VAL POINTERS > GROUPS > LOGIC

## Examples
# Attach this to a chest that is openable when the player has a key in their inventory.
# This would be using a generalized node for interaction for things like opening doors and talking to npcs
# HOWEVER, it would only trigger on our side if the source that enters us has my_component_inventory.search("key") > 1
# Then just do my_component_inventory.consume("key",1) on interact and trigger the chest going to "open" state

# Attach this to a node that needs to be "activated" by a certain piece of equipment
# This would be a specialized interaction area defined by the equipment, so we can do things
# like hookshot hardpoints, teleportation points, look-at-interaction, etc

# Attach this to an NPC to trigger their talk dialogue by connecting the NPC to the interact signal

@icon("res://Art/icons/node icons/node_3D/icon_signal.png")

class_name component_interact_reciever
extends Area3D

@onready var my_component_impulse_controller : component_impulse_controller = get_my_component_impulse_controller()

signal enter(source : Node)
signal exit(source : Node)
signal interact(source : Node)

func get_my_component_impulse_controller():
	if get_parent() is component_impulse_controller:
		return get_parent()
	else:
		push_error("component_interact_reciever must be a child of component_impulse_controller")
		push_error("Could not find component_impulse_controller for ",name," in ",get_parent())
