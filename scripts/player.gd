extends CharacterBody3D

@onready var my_component_health: component_health = %Components/component_health
@onready var my_component_ability: component_ability = %Components/component_ability
@onready var my_component_state_controller: component_state_controller = %Components/component_state_controller
@onready var my_component_input_controller: component_input_controller = %Components/component_input_controller
@onready var my_battle_gui : Control = %Battle_GUI

#HACK Yeah just to answering anyone who might be getting this error and sees this post, 
#I manage to fix it preloading every timelines I needed when I enter the game. So basically, 
#you need to preload your style AND your timelines, just use Dialogic.preload_timeline and youre smooth to go 
#HACK DON'T USE ONREADY WITHOUT A REASON. ONREADY ONLY RUNS FOR SCENES PRE-LAUNCH
#INSTANTIATED SCENES IGNORE @ONREADY FOR SOME FUCKING REASON, OR JUST TAKE TOO LONG
#HACK sprite.texture.get_width() and sprite.texture.get_height() for spacing
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

#Setting var for state machine
@onready var state_chart: StateChart = %StateChart
@onready var state_subchart := %StateChart/Main
@onready var state_subchart_battle := %StateChart/Main/Battle
@onready var state_init_override = null

#Animations init
@onready var anim_root : Node3D = %Animations
@onready var anim_tree : AnimationTree = %Animations/character_animation_tree
@onready var anim : AnimationPlayer = %Animations/character_animation_player
@onready var sprite : AnimatedSprite3D = %Animations/character_animation_sprite

#TODO WHEN ADDING PICKER FOR WHO TO ATTACK, USE TRANSPARENCY sprite.modulate = Color(1,1,1,0.5)

func _ready() -> void:
	
	#Dialogic
	#Dialogic.preload_timeline

	#Abilities
	var abil = my_component_ability
	abil.my_abilities = [abil.ability_tackle.new(self),abil.ability.new(self),abil.ability.new(self),abil.ability.new(self)]
	
	#HACK for debug to see diff players
	name = str(name," ",randi())
	
	#FUCK this animation tree shit sometimes
	anim_tree.active = true

func _set_viewport_mat(_display_mesh : MeshInstance3D, _sub_viewport : SubViewport, _surface_id : int = 0):
	var _mat : StandardMaterial3D = StandardMaterial3D.new()
	_mat.albedo_texture = _sub_viewport.get_texture()
	_display_mesh.set_surface_override_material(_surface_id, _mat)

func _physics_process(_delta: float) -> void:
	
	#if Input.is_action_just_pressed("debug"):
		#if !Global.debug:
			#$StateChartDebugger.enabled = true
			#Global.debug = true
		#else:
			#$StateChartDebugger.enabled = false
			#Global.debug = false
	
	if Input.is_action_just_pressed("interact"):
		#Dialogic.start("timeline")
		anim_tree.get("parameters/playback").travel("Attack")
		
	
	# MAKE SURE YOU UNDERSTAND THE ORDER OF THE OBJECT IS THE ORDER THEY WILL TAKE TURNS IN LATER
	if Input.is_action_just_pressed("ui_cancel"):
		Battle.battle_initialize(["player","player","enemy","enemy"],[{},{},{},{}],owner.get_tree(),"res://scenes/turn_arena.tscn")
	
