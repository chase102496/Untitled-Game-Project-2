extends CharacterBody3D

#region Init Values

#Setting var for state machine
@onready var state_chart: StateChart = get_node("StateChart")
@onready var state_subchart = get_node("StateChart/Main")
@onready var state_init_override = null

#Animations init
@onready var anim_tree = get_node("AnimationTree")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D")

#HACK DON'T USE ONREADY WITHOUT A REASON. ONREADY ONLY RUNS FOR SCENES PRE-LAUNCH
#INSTANTIATED SCENES IGNORE @ONREADY FOR SOME FUCKING REASON, OR JUST TAKE TOO LONG
var stats : Dictionary = {
	
	"alignment" : "friends", #Side of the field I will fight on
	"glossary" : "player", #Unit category I was spawned from
	"spacing" : Vector3(-0.6,0,-0.1), #spacing when unit is spawned in battle
	
	"health" : 6,
	"max_health" : 6,
	
	"vis" : 6,
	"max_vis" : 6,
	
	"skillcheck_difficulty_mod" : 1.0
}

#TODO WHEN ADDING PICKER FOR WHO TO ATTACK, USE TRANSPARENCY sprite.modulate = Color(1,1,1,0.5)

#endregion

func _ready() -> void:
	
	#recieving signals from state machine
	#HACK: state_chart.get_child(0).get_current_state() shows current state of our first system (Main)
	#region Signals
	
	#Connecting to battle signaling system,
	#Battle.active_character.connect()
	Events.turn_start.connect(_on_battle_turn_start)
	
	$StateChart/Main/Explore.state_physics_processing.connect(_on_state_physics_processing_explore)
	
	#endregion

#region Modules
	
func animations_init(dir : Vector2 = Vector2(0,0)):
	anim_tree.get("parameters/playback").travel("Idle")
	anim_tree.set("parameters/Idle/BlendSpace2D/blend_position",dir)

#endregion

func _on_state_physics_processing_explore(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
			Dialogic.start("timeline")

#	--- State Machine ---

func _on_battle_turn_start():
	if Battle.active_character == self:
		print(self)
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
