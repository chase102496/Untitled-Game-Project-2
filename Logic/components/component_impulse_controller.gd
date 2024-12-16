class_name component_impulse_controller
extends component_impulse

## This will allow us to listen for an area to allow the interaction to be sent in
@export var my_component_interact_reciever : component_interact_reciever

## If plugged in, the impulse controller will only work when this is active, acting as an internal AND gate
@export var impulse_parent : component_impulse
@onready var state_chart : StateChart = $StateChart

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

func _on_impulse_parent_activated() -> void:
	impulse_parent_signal = true

func _on_impulse_parent_deactivated() -> void:
	impulse_parent_signal = false

## Wrapper for updating states
## ALWAYS use this to transition so we properly update things.
func my_state_transition(old_state_name : String, new_state_name : String, ignore_collision : bool = false) -> void:
	
	#Prevent recursion if this transition ends up calling itself anywhere. Only one process at a time.
	if !is_transitioning:
		
		#If we have a controller attached that is enabling/disabling this controller, we check for its value
		if !impulse_parent or impulse_parent_signal:
			
			is_transitioning = true
			
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
	else:
		#print_debug("state transition for ",self," busy.")
		pass

## Wrapper for updating all signals
func update_signals(state_name : String, toggle : bool):
	if toggle:
		my_component_interact_reciever.enter.connect(Callable(self,str("_on_target_entered_",state_name)))
		my_component_interact_reciever.exit.connect(Callable(self,str("_on_target_exited_",state_name)))
		my_component_interact_reciever.interact.connect(Callable(self,str("_on_target_interact_",state_name)))
	else:
		my_component_interact_reciever.enter.disconnect(Callable(self,str("_on_target_entered_",state_name)))
		my_component_interact_reciever.exit.disconnect(Callable(self,str("_on_target_exited_",state_name)))
		my_component_interact_reciever.interact.disconnect(Callable(self,str("_on_target_interact_",state_name)))

## Wrapper for updating area collision
func update_collision(toggle : bool):
	my_component_interact_reciever.set_collision_mask_value(5,toggle)
	my_component_interact_reciever.set_collision_layer_value(5,toggle)
