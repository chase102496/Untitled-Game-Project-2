@icon("res://Art/icons/node icons/node_3D/icon_lever.png")

class_name component_impulse_controller
extends component_impulse


signal activated
signal deactivated
signal activated_load
signal deactivated_load

## If plugged in, the impulse controller will only work when this is active, acting as an internal AND gate
@export var impulse_parent : component_impulse

## This is what we get our signals from, usually an Area3D
@onready var my_component_interact_reciever : component_interact_reciever = get_my_component_interact_reciever()

## The delay after changing states

var interact_timer : Timer = Timer.new()
@export_range(0.1,10,0.1) var interact_timer_max : float = 0.25

@onready var state_chart : StateChart = $StateChart
@onready var state_chart_initial_state = $StateChart/Main.initial_state
@onready var debug_name : String = get_parent().get_parent().name

## Just keeps track of our impulse parent, if we have one
var impulse_parent_signal : bool

func _ready() -> void:
	## Important info
	# Whenever you change states, you HAVE to use my_state_transition.
	# If you ARE currently COLLIDING areas with the player when changing states, use ignore_collision = false.
	# Otherwise, true
	
	interact_timer.one_shot = true
	add_child(interact_timer)
	interact_timer.timeout.connect(_on_interact_timer_timeout)
	
	if impulse_parent:
		impulse_parent.activated.connect(_on_impulse_parent_activated)
		impulse_parent.deactivated.connect(_on_impulse_parent_deactivated)

func _start_interact_timer() -> void:
	interact_timer.start(interact_timer_max)

func _stop_interact_timer() -> void:
	interact_timer.stop()

func _is_interact_timer_running() -> bool:
	return !interact_timer.is_stopped()

func _on_interact_timer_timeout() -> void:
	print(interact_timer.is_stopped())

func get_my_component_interact_reciever():
	for child in get_children():
		if child is component_interact_reciever:
			return child
	
	push_error("Could not find component_interact_reciever for ",name," in ",get_parent())

func _on_impulse_parent_activated() -> void:
	impulse_parent_signal = true

func _on_impulse_parent_deactivated() -> void:
	impulse_parent_signal = false
