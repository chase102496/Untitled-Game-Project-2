class_name component_physics
extends component_node

#For functions, emit a signal, and then just connect it on the parent end and create a function to run when it is signalled

#Use "owner" to call our owner

var grav : float # Realtime gravity adding

var _enabled : bool = true
var _collision : bool = true
var _friction : bool = true
#var _gravity : bool = true

var collision_prev : Dictionary = {}
var velocity_history : Array = []

@export var base_grav : float = 35 # To revert to our default
@export var max_grav : float = -70 # Our max downward velocity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grav_reset()

### --- Public --- ###

func enable() -> void:
	enable_collision()
	enable_friction()
	_enabled = true

func disable() -> void:
	disable_collision()
	disable_friction()
	_enabled = false

func enable_collision():
	
	#for i in 32:
		#if i != 0:
			#owner.set_collision_layer_value(i,collision_prev[i])
	#
	_collision = true

func disable_collision():
	
	#for i in 32:
		#if i != 0:
			#collision_prev[i] = owner.get_collision_layer_value(i)
			#owner.set_collision_layer_value(i,false)
	
	_collision = false

func enable_friction():
	_friction = true

func disable_friction():
	_friction = false

func grav_reset() -> void:
	grav = base_grav

### --- Velocity History --- ###

func _clean_velocity_history() -> void:
	## Limit to 60 units
	if velocity_history.size() > 60:
		velocity_history.pop_front()
		_clean_velocity_history()

func _store_velocity_history() -> void:
	velocity_history.append(owner.velocity)
	_clean_velocity_history()

func get_velocity_history(depth : int = 60) -> Array:
	
	if depth > 60:
		push_error("Velocity History is not stored for more than 60 previous frames : ",depth)
		return velocity_history
	else:
		return velocity_history.slice(velocity_history.size() - depth)

### --- Physics Runtime --- ###

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if _enabled:
		_store_velocity_history()
		
		
		
		if _friction:
			owner.move_and_slide()
			
			owner.velocity.y = move_toward(owner.velocity.y, max_grav, grav * delta)
