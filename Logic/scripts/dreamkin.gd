extends CharacterBody3D

#Battle entity
@onready var my_component_health: component_health = %Components/component_health
@onready var my_component_vis: component_vis = %Components/component_vis
@onready var my_component_ability: component_ability = %Components/component_ability
@onready var my_component_status_effect_controller: component_status_effect_controller = %Components/component_status_effect_controller
@onready var my_component_state_controller_battle: component_state_controller_battle = %Components/component_state_controller_battle

#Statecharts
@onready var state_chart: StateChart = %StateChart
@onready var state_subchart_battle := %StateChart/Main/Battle
@onready var state_init_override = null
#Animations
@onready var anim_root : Node3D = %Animations
@onready var anim_tree : AnimationTree = %Animations/character_animation_tree
@onready var anim_player : AnimationPlayer = %Animations/character_animation_player
@onready var sprite : AnimatedSprite3D = %Animations/character_animation_sprite
#Player or Dreamkin
@onready var my_component_input_controller: component_input_controller_follow = %Components/component_input_controller_follow
@onready var my_battle_gui : Control = %Battle_GUI

var stats : Dictionary = {
	"alignment" : Global.alignment.FRIENDS, #Side of the field I will fight on
	"glossary" : "dreamkin", #Unit category I was spawned from
	"spacing" : Vector3(0.9,0,-0.1), #spacing when unit is spawned in battle
}

func _ready() -> void:
	#Debug
	#name = str(name," ",randi())
	#Dialogic
	Dialogic.preload_timeline("res://timeline.dtl")
	#Abilities
	var abil = my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(self),
		abil.ability_solar_flare.new(self),
		abil.ability.new(self),
		abil.ability.new(self)
		]
	#FUCK this animation tree shit sometimes
	anim_tree.active = true
