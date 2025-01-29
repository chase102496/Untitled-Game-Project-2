## Handles general interaction not reliant on equipment or really specific player parameters
## For things like opening other nodes like doors, talking to NPCs, etc
## This is the TRANSMITTER or HOST
## For recievers, like an NPC or a lever, use component_interact_reciever
class_name component_interaction
extends component_node_3d

@export var active_interact_area : component_interact_controller

var _disabled : bool = false

func _ready() -> void:
	
	#Disabled
	%StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	%StateChart/Main/Disabled.state_exited.connect(_on_state_exited_disabled)
	
	active_interact_area.area_entered.connect(_on_active_interact_area_entered)
	active_interact_area.area_exited.connect(_on_active_interact_area_exited)

func _on_state_entered_disabled() -> void:
	_disabled = true
	
	#await get_tree().create_timer(0.3).timeout #cope
	#active_interact_area.shape.disabled = true

func _on_state_exited_disabled() -> void:
	_disabled = false
	
	#await get_tree().create_timer(0.3).timeout #cope
	#active_interact_area.shape.disabled = false

func verify(source : Node) -> bool:
	if source.is_in_group("interact_general"):
		return true
	else:
		return false

func interact() -> void:
	for area in active_interact_area.get_overlapping_areas():
		if verify(area):
			area.interact.emit(owner)

func _on_active_interact_area_entered(area : Area3D) -> void:
	if verify(area):
		area.enter.emit(owner)

func _on_active_interact_area_exited(area : Area3D) -> void:
	if verify(area):
		area.exit.emit(owner)
