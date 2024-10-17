extends CharacterBody3D

#region Init Values

#Setting var for state machine
@onready var state_chart: StateChart = get_node("StateChart")
@onready var state_subchart = get_node("StateChart/Main")
@onready var state_init_override = null

#region Stats

@export_group("Stats")

@export var health := 6
@export var vis := 6

#endregion

#Animations init
@onready var anim_tree = get_node("AnimationTree")

#Inputs init
var direction := Vector2.ZERO
var jumping := false
var jump_start := false

#Physics
var max_run := 3.2 #8
var run_accel := 50 #70
var grav := 40
var max_grav := -70
var jump_force := 10
var grounded := false
var jump_damper := 1
var current_state = null

#endregion

func _ready() -> void:

	#recieving signals from state machine
	#HACK: state_chart.get_child(0).get_current_state() shows current state of our first system
	
	#region Signals
	
	#Connecting to dialogue signals
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	#	State Machine Signals
	
	#Battle
	$StateChart/Main/Battle.state_physics_processing.connect(_on_state_physics_processing_battle)
	#Physics
	$StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	$StateChart/Main/Explore/Idle.state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	$StateChart/Main/Explore/Walking.state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	#Entered
	$StateChart/Main/Pause_Input.state_entered.connect(_on_state_entered_pause_input)
	
	#endregion

#region Modules

func inputs_init():
	direction = Vector2.ZERO
	jumping = false
	jump_start = false
func animations_init():
	anim_tree.get("parameters/playback").travel("Idle")
func input_handler():
	#Physics controls inputs
	jump_start = Input.is_action_just_pressed("move_jump")
	jumping = Input.is_action_pressed("move_jump")
	direction = Input.get_vector("move_right","move_left","move_forward","move_backward")

	#testing transition to turn-based
	if Input.is_action_just_pressed("ui_cancel"):
		#TODO editing
		var unit = Battle.unit_player
		var friends = [unit,unit]
		var foes = [unit,unit]
		Battle.set_battle_list(friends, foes)
		
		get_tree().change_scene_to_file("res://scenes/turn_arena3d.tscn")
	
	#testing dialogue
	if Input.is_action_just_pressed("interact"):
		Dialogic.start("timeline")

#endregion

#Dialogue signals
func _on_dialogic_signal(arg:String) -> void:
	#pass on the string from dialogue signal to state machine
	state_chart.send_event(arg)

#	--- State Machine ---

#Battle state and sub-states
func _on_state_physics_processing_battle(_delta: float):
	pass

#Explore state and sub-states
func _on_state_init_override(state: String):
	state_chart.send_event(state)
func _on_state_physics_processing_explore(_delta: float):
	input_handler()
func _on_state_physics_processing_explore_idle(_delta: float):
	
	if Input.is_action_pressed("battle"):
		state_chart.send_event("on_start_battle")
	
	anim_tree.get("parameters/playback").travel("Idle")
	
	if direction != Vector2.ZERO:
		state_chart.send_event("on_walking")
func _on_state_physics_processing_explore_walking(_delta: float):
	if direction == Vector2.ZERO:
		state_chart.send_event("on_idle")
	else:
		anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",direction)
		anim_tree.set("parameters/Walking/BlendSpace2D/blend_position",direction)
		anim_tree.get("parameters/playback").travel("Walking")

#Pause state and sub-states
func _on_state_entered_pause_input():
	#Resets inputs
	inputs_init()
	#Reset animation to idle
	animations_init()

#Always runs
func _process(_delta: float) -> void:
	#TODO
	if state_init_override:
		state_chart.send_event(state_init_override)
		state_init_override = null
	pass

#Always runs
func _physics_process(delta: float) -> void:

	move_and_slide()
	
	#Applying jump
	if jump_start:
		if is_on_floor():
			velocity.y = jump_force
	
	#TODO add state machine for in-air stuff
	if !jumping and !is_on_floor() and velocity.y > 0:
		velocity.y -= move_toward(0,velocity.y,jump_damper)
		#get_tree().change_scene_to_file("res://turn_arena.tscn")
	
	#Applying movement
	velocity.x = move_toward(velocity.x, max_run * -direction.x, run_accel * delta)
	velocity.z = move_toward(velocity.z, max_run * direction.y, run_accel * delta)
	velocity.y = move_toward(velocity.y, max_grav, grav * delta)
