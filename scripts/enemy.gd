extends CharacterBody3D

@onready var my_component_health: component_health = %Components/component_health
@onready var my_component_ability: component_ability = %Components/component_ability
@onready var my_component_state_controller: component_state_controller = %Components/component_state_controller

var stats : Dictionary = {
	
	"alignment" : "foes", #Side of the field I will fight on, maybe later a component we could make could have a script to change sides
	"glossary" : "enemy", #Unit category I was spawned from
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
@onready var anim_tree : AnimationTree = %Animations/character_animation_tree
@onready var anim : AnimationPlayer = %Animations/character_animation_player
@onready var sprite : AnimatedSprite3D = %Animations/character_animation_sprite

func _ready() -> void:
	
	if my_component_ability:
		var abil = my_component_ability
		abil.my_abilities = [abil.ability_tackle.new(self)]
	
	#HACK for debug to see diff characters
	name = str(name," ",randi())
	
	#FUCK this animation tree shit sometimes
	anim_tree.active = true
