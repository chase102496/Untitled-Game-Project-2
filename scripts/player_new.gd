extends CharacterBody3D

#region Init Values

#Setting var for state machine
@onready var state_chart: StateChart = get_node("StateChart")

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
	#recieving signals from dialogue and sending to func
	Dialogic.signal_event.connect(_on_dialogic_signal)
	#recieving signals from state machine
	#HACK: state_chart.get_child(0).get_current_state() shows current state of our first system
	#$StateChart/CompoundState/Default.state_processing.connect(_on_state_processing_default)
	
	#Physics runtimes
	$StateChart/CompoundState/Default.state_physics_processing.connect(_on_state_physics_processing_default)
	$StateChart/CompoundState/Default/Idle.state_physics_processing.connect(_on_state_physics_processing_idle)
	$StateChart/CompoundState/Default/Walking.state_physics_processing.connect(_on_state_physics_processing_walking)
	$StateChart/CompoundState/Pause_Input.state_entered.connect(_on_state_entered_pause_input)

#region Modules for runtimes

func inputs_init():
	direction = Vector2.ZERO
	jumping = false
	jump_start = false

func input_handler():
	#Physics controls inputs
	jump_start = Input.is_action_just_pressed("move_jump")
	jumping = Input.is_action_pressed("move_jump")
	direction = Input.get_vector("move_right","move_left","move_forward","move_backward")

	#testing transition to turn-based
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/turn_arena3d.tscn")
	
	#testing dialogue
	if Input.is_action_just_pressed("interact"):
		#TODO need to add state machines now for dialogue
		Dialogic.start("timeline")
		state_chart.send_event("on_chat_start")

#endregion

#Dialogue signals
func _on_dialogic_signal(arg:String) -> void:
	#pass on the string from dialogue signal to state machine
	state_chart.send_event(arg)

#region state charts

func _on_state_physics_processing_idle(_delta: float):
	
	anim_tree.get("parameters/playback").travel("Idle")
	
	if direction != Vector2.ZERO:
		state_chart.send_event("on_walking")

func _on_state_physics_processing_walking(_delta: float):
	if direction == Vector2.ZERO:
		state_chart.send_event("on_idle")
	else:
		anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",direction)
		anim_tree.set("parameters/Walking/BlendSpace2D/blend_position",direction)
		anim_tree.get("parameters/playback").travel("Walking")

#Pause input
func _on_state_entered_pause_input():
	inputs_init()
	print(direction)
	print(velocity)

#Inputs, and physics stuff for default player core
func _on_state_physics_processing_default(_delta: float):
	input_handler()

#Runs during pause input state
func _on_state_physics_processing_pause_input():
	pass

#endregion

#Always runs
func _process(_delta: float) -> void:
	pass

#TODO Animations

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
