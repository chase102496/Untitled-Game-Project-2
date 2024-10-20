extends CharacterBody3D

#region init public vars

# An array of functions that we use to cast our abilities off of.
var my_abilities = [Ability.simple_print,Ability.test_ability]

@warning_ignore("shadowed_global_identifier")
@onready var component_state_controller: component_state_controller = $Components/component_state_controller
@warning_ignore("shadowed_global_identifier")
@onready var component_movement: component_movement = $Components/component_movement
@warning_ignore("shadowed_global_identifier")
@onready var component_animation_controller: component_animation_controller = $Components/component_animation_controller
@warning_ignore("shadowed_global_identifier")
@onready var component_physics: component_physics = $Components/component_physics
@warning_ignore("shadowed_global_identifier")
@onready var component_ability: Node = $Components/component_ability

#HACK DON'T USE ONREADY WITHOUT A REASON. ONREADY ONLY RUNS FOR SCENES PRE-LAUNCH
#INSTANTIATED SCENES IGNORE @ONREADY FOR SOME FUCKING REASON, OR JUST TAKE TOO LONG

#TODO prob gonna get rid of this and turn into component
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

#endregion

#region @onready public vars

#Setting var for state machine
@onready var state_chart: StateChart = get_node("StateChart")
@onready var state_subchart := get_node("StateChart/Main")
@onready var state_init_override = null

#Animations init
@onready var anim_tree := get_node("AnimationTree")
@onready var sprite : AnimatedSprite3D = get_node("AnimatedSprite3D")

#TODO WHEN ADDING PICKER FOR WHO TO ATTACK, USE TRANSPARENCY sprite.modulate = Color(1,1,1,0.5)

#endregion

func _ready() -> void:
	
	#recieving signals from state machine
	#HACK: state_chart.get_child(0).get_current_state() shows current state of our first system (Main)
	#region Signals
	
	#Connecting to battle signaling system,
	#Battle.active_character.connect()
	Events.turn_start.connect(_on_battle_turn_start)
	
	#endregion

#region Modules

#endregion

#	--- State Machine ---

func _on_battle_turn_start():
	if Battle.active_character == self:
		print(self)

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("battle"):
		anim_tree.get("parameters/playback").travel("test")
		#if Battle.battle_list[0] == self:
			#print(self.name)
			#component_ability.click_of_death(Battle.battle_list[3])
