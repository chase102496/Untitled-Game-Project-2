extends CharacterBody3D

#region init public vars
@onready var my_component_health: component_health = $Components/component_health
@onready var my_component_ability: component_ability = $Components/component_ability
@onready var my_component_state_controller: component_state_controller = $Components/component_state_controller
@onready var my_component_movement_controller: component_movement_controller = $Components/component_movement_controller
@onready var my_component_input_controller: component_input_controller = $Components/component_input_controller
@onready var my_component_animation_controller: component_animation_controller = $Components/component_animation_controller
@onready var my_component_physics: component_physics = $Components/component_physics

@onready var my_battle_gui : Control = $Battle_GUI

#HACK DON'T USE ONREADY WITHOUT A REASON. ONREADY ONLY RUNS FOR SCENES PRE-LAUNCH
#INSTANTIATED SCENES IGNORE @ONREADY FOR SOME FUCKING REASON, OR JUST TAKE TOO LONG

#TODO prob gonna get rid of this and turn into component!!!
#TODO COMPONENTS!!!
var stats : Dictionary = {
	
	"alignment" : "friends", #Side of the field I will fight on, maybe later a component we could make could have a script to change sides
	"glossary" : "player", #Unit category I was spawned from
	"spacing" : Vector3(-0.6,0,-0.1), #spacing when unit is spawned in battle
	
	"vis" : 6, #component
	"max_vis" : 6,
	
	"skillcheck_difficulty_mod" : 1.0 #component
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
	
	#HACK for debug to see diff players
	name = str(name," ",randi())

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass
