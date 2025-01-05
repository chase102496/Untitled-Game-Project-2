class_name component_impulse_controller
extends component_impulse

signal activated
signal deactivated

## This will allow us to listen for an area to allow the interaction to be sent in


## If plugged in, the impulse controller will only work when this is active, acting as an internal AND gate
@export var impulse_parent : component_impulse

## This is what we get our signals from, usually an Area3D
@onready var my_component_interact_reciever : component_interact_reciever = get_my_component_interact_reciever()

@onready var state_chart : StateChart = $StateChart
@onready var state_chart_initial_state = $StateChart/Main.initial_state
@onready var debug_name : String = get_parent().get_parent().name

## Just keeps track of our impulse parent, if we have one
var impulse_parent_signal : bool

## Used to prevent multiple transitions at once, favoring the first call
var is_transitioning : bool = false

func _ready() -> void:
	## Important info
	# Whenever you change states, you HAVE to use my_state_transition.
	# If you ARE currently COLLIDING areas with the player when changing states, use ignore_collision = false.
	# Otherwise, true
	
	if impulse_parent:
		impulse_parent.activated.connect(_on_impulse_parent_activated)
		impulse_parent.deactivated.connect(_on_impulse_parent_deactivated)

func get_my_component_interact_reciever():
	for child in get_children():
		if child is component_interact_reciever:
			return child
	
	push_error("Could not find component_interact_reciever for ",name," in ",get_parent())

func _on_impulse_parent_activated() -> void:
	impulse_parent_signal = true

func _on_impulse_parent_deactivated() -> void:
	impulse_parent_signal = false

func my_state_transition_toggle(ignore_collision : bool = false, mirror : bool = false) -> void:
	
	var state_dest : String
	
	if state_chart.get_current_state() == "Activated":
		state_dest = "deactivated"
	else:
		state_dest = "activated"
	
	my_state_transition(state_chart.get_current_state(),state_dest,ignore_collision,mirror)
	
## Wrapper for updating states
## ALWAYS use this to transition so we properly update things.
func my_state_transition(
	old_state_name : String, new_state_name : String,
	ignore_collision : bool = false,
	mirror : bool = false
	) -> void:
	
	#Prevent recursion if this transition ends up calling itself anywhere. Only one process at a time.
	if !is_transitioning:
		
		#If we have a controller attached that is enabling/disabling this controller, we check for its value
		if !impulse_parent or impulse_parent_signal:
			
			is_transitioning = true
			
			## If I'm currently linked with heartlink and this isn't already a heartlink sourced signal
			if is_in_group("interact_ability_heartlink_active") and !mirror:
				#for child in get_tree().get_nodes_in_group("interact_ability_heartlink_active"):
					#if child.impulse_parent and child.impulse_parent == self: #If we find someone we're controlling
						#pass
				get_tree().call_group("interact_ability_heartlink_active","my_state_transition_toggle",true,true)
			
			## If we're running a state change with no need for collision updates
			if ignore_collision:
				
				update_signals(old_state_name, false)
				update_signals(new_state_name, true)
				state_chart.send_event(str("on_",new_state_name))
			
			## If we're running a state change with a need for collision updates
			else:
				
				#Set mask to trigger exit collision
				update_collision(false)
				
				#Wait for exit signal from player to transfer to us
				await my_component_interact_reciever.exit
				
				#Disconnect
				update_signals(old_state_name, false)
				
				#Setup new signals for new state
				update_signals(new_state_name, true)
				
				#Set mask to trigger enter collision
				update_collision(true)
				
				#Wait for signal from player
				await my_component_interact_reciever.enter
				
				#Transfer to new state
				state_chart.send_event(str("on_",new_state_name))
			
			is_transitioning = false
		#This runs when we have an impulse parent
		else:
			pass
	else:
		#print_debug("state transition for ",self," busy.")
		pass

## Wrapper for updating all signals
func update_signals(state_name : String, is_connecting : bool, passive : bool = false):
	
	var call_enter : Callable = Callable(self,str("_on_target_entered_",state_name))
	var call_exit : Callable = Callable(self,str("_on_target_exited_",state_name))
	var call_interact : Callable = Callable(self,str("_on_target_interact_",state_name))
	
	# Checking if we transition without player interaction
	if passive:
		if is_connecting:
			if !my_component_interact_reciever.enter.is_connected(call_enter):
				my_component_interact_reciever.enter.connect(call_enter)
				my_component_interact_reciever.exit.connect(call_exit)
				my_component_interact_reciever.interact.connect(call_interact)
		else:
			if my_component_interact_reciever.enter.is_connected(call_enter):
				my_component_interact_reciever.enter.disconnect(call_enter)
				my_component_interact_reciever.exit.disconnect(call_exit)
				my_component_interact_reciever.interact.disconnect(call_interact)
	else:
		if is_connecting:
			my_component_interact_reciever.enter.connect(call_enter)
			my_component_interact_reciever.exit.connect(call_exit)
			my_component_interact_reciever.interact.connect(call_interact)
		else:
			my_component_interact_reciever.enter.disconnect(call_enter)
			my_component_interact_reciever.exit.disconnect(call_exit)
			my_component_interact_reciever.interact.disconnect(call_interact)

## Wrapper for updating area collision
func update_collision(toggle : bool):
	my_component_interact_reciever.set_collision_mask_value(5,toggle)
	my_component_interact_reciever.set_collision_layer_value(5,toggle)
