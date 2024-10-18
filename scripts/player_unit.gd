extends CharacterBody3D

#region Init Values

#Setting var for state machine
@onready var state_chart: StateChart = get_node("StateChart")
@onready var state_subchart = get_node("StateChart/Main")
@onready var state_init_override = null

#Animations init
@onready var anim_tree = get_node("AnimationTree")

#HACK DON'T USE ONREADY WITHOUT A REASON. ONREADY ONLY RUNS FOR SCENES PRE-LAUNCH
#INSTANTIATED SCENES IGNORE @ONREADY FOR SOME FUCKING REASON, OR JUST TAKE TOO LONG
var stats : Dictionary = {
	
	"alignment" : "friends", #Side of the field I will fight on
	"glossary" : "player", #Unit category I was spawned from
	"spacing" : Vector3(-0.3,0,-0.1), #spacing when unit is spawned in battle
	
	"health" : 6,
	"max_health" : 6,
	
	"vis" : 6,
	"max_vis" : 6,
	
	"skillcheck_difficulty_mod" : 1.0,
	
	#Physics
	"movespeed" : 50,
	"max_movespeed" : 3.2,
	"jump" : 10,
	"jump_damper" : 1,
	"grav" : 40,
	"max_grav" : -70
	
}

#Inputs init
var direction := Vector2.ZERO
var jumping := false
var jump_start := false

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

	#FIXME testing transition to turn-based ----------------------------------------------------------------------------------------------
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize([self,self,self,self],[{"test":123},{"ababab":60000000},{},{}],get_tree(),"res://scenes/turn_arena3d.tscn")
	
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
			velocity.y = stats.jump
	
	#TODO add state machine for in-air stuff
	if !jumping and !is_on_floor() and velocity.y > 0:
		velocity.y -= move_toward(0,velocity.y,stats.jump_damper)
		#get_tree().change_scene_to_file("res://turn_arena.tscn")
	
	#Applying movement
	velocity.x = move_toward(velocity.x, stats.max_movespeed * -direction.x, stats.movespeed * delta)
	velocity.z = move_toward(velocity.z, stats.max_movespeed * direction.y, stats.movespeed * delta)
	velocity.y = move_toward(velocity.y, stats.max_grav, stats.grav * delta)
