extends Node3D

@export var my_interact_component : Area3D
@onready var state_chart : StateChart = $StateChart

func _ready() -> void:
	
	#Initial state
	my_state_signals_init("deactivated")
	
	$StateChart/Main/Deactivated.state_entered.connect(on_state_entered_deactivated)
	$StateChart/Main/Deactivated.state_exited.connect(on_state_exited_deactivated)
	$StateChart/Main/Activated.state_entered.connect(on_state_entered_activated)
	$StateChart/Main/Activated.state_exited.connect(on_state_exited_activated)
	
	## Important info
	# Whenever you change states, you HAVE to use my_state_transition.
	# If the player isn't inside your object's interact range or you don't need to manipulate things,
	# use ignore collision = true.
	# However;
	# If you need to update info and something changes across states that you need to update for the player
	# like seeing if they're still in the box with you when they interact or something being reliant on
	# target_entered or target_exited,
	# Make sure you do NOT ignore collision (so ignore_collision = false or leave blank)
	# For changing states upon exiting your area, use ignore_collision = true.
	# For changing states upon entering your area, use ignore_collision = false.

## Wrapper for updating states when there's an active collision. Essentially resets colliders
func my_state_transition(old_state_name : String, new_state_name : String, ignore_collision : bool = false) -> void:
	
	## TODO might need to change this condition to be more precise
	if !ignore_collision and my_interact_component.has_overlapping_areas(): #For state changes when colliding with stuff
		
		#Set mask to trigger exit collision
		update_collision(false)
		
		#Wait for exit signal from player
		await my_interact_component.exit
		
		#Disconnect
		update_signals(old_state_name, false)
		
		#Setup new signals for new state
		update_signals(new_state_name, true)
		
		#Set mask to trigger enter collision
		update_collision(true)
		
		#Wait for signal from player
		await my_interact_component.enter
		
		#Transfer to new state
		state_chart.send_event(str("on_",new_state_name))
		
	else:
		my_state_signals_cleanup(old_state_name)
		my_state_signals_init(new_state_name)
		state_chart.send_event(str("on_",new_state_name))

## Wrapper for updating all signals
func update_signals(state_name : String, toggle : bool):
	if toggle:
		my_interact_component.enter.connect(Callable(self,str("_on_target_entered_",state_name)))
		my_interact_component.exit.connect(Callable(self,str("_on_target_exited_",state_name)))
		my_interact_component.interact.connect(Callable(self,str("_on_target_interact_",state_name)))
	else:
		my_interact_component.enter.disconnect(Callable(self,str("_on_target_entered_",state_name)))
		my_interact_component.exit.disconnect(Callable(self,str("_on_target_exited_",state_name)))
		my_interact_component.interact.disconnect(Callable(self,str("_on_target_interact_",state_name)))

## Wrapper for updating area collision
func update_collision(toggle : bool):
	my_interact_component.set_collision_mask_value(5,toggle)
	my_interact_component.set_collision_layer_value(5,toggle)

## Wrapper for normal state exit cleanup
func my_state_signals_cleanup(state_name : String) -> void:
	
	update_collision(false)
	
	if my_interact_component.has_overlapping_areas(): #Await exited command to update colliders inside
		await my_interact_component.exit
	
	update_signals(state_name, false)

## Wrapper for normal state enter cleanup
func my_state_signals_init(state_name : String) -> void:
	
	update_signals(state_name, true)
	update_collision(true)

## --- Deactivated --- ###

func on_state_entered_deactivated() -> void:
	$FogVolume.material.set_shader_parameter("color", Color("8000ff"))

#

func _on_target_entered_deactivated(source : Node) -> void:
	print("_on_target_entered_deactivated")

func _on_target_exited_deactivated(source : Node) -> void:
	print("_on_target_exited_deactivated")

func _on_target_interact_deactivated(source : Node) -> void:
	print("_on_target_interact_deactivated")
	my_state_transition("deactivated","activated")

#

func on_state_exited_deactivated() -> void:
	pass

## --- Activated --- ##

func on_state_entered_activated() -> void:
	$FogVolume.material.set_shader_parameter("color", Color("00ff33"))

#

func _on_target_entered_activated(source : Node) -> void:
	print("_on_target_entered_activated")

func _on_target_exited_activated(source : Node) -> void:
	print("_on_target_exited_activated")
	###
	my_state_transition("activated","deactivated",true) #ignore collider check

func _on_target_interact_activated(source : Node) -> void:
	print("_on_target_interact_activated")
	my_state_transition("activated","deactivated")

#

func on_state_exited_activated() -> void:
	pass
