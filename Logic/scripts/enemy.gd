extends CharacterBody3D

#Battle entity
@onready var my_component_health: component_health = %Components/component_health
@onready var my_component_vis: component_vis = %Components/component_vis
@onready var my_component_ability: component_ability = %Components/component_ability
@onready var my_component_state_controller_battle: component_state_controller_battle = %Components/component_state_controller_battle
@onready var my_component_status_effect_controller: component_status_effect_controller = %Components/component_status_effect_controller
#Statecharts
@onready var state_chart: StateChart = %StateChart
@onready var state_subchart_battle := %StateChart/Main/Battle
@onready var state_init_override = null
#Animations
@onready var anim_root : Node3D = %Animations
@onready var anim_tree : AnimationTree = %Animations/character_animation_tree
@onready var anim_player : AnimationPlayer = %Animations/character_animation_player
@onready var sprite : AnimatedSprite3D = %Animations/character_animation_sprite

var stats : Dictionary = {
	"alignment" : Global.alignment.FOES, #Side of the field I will fight on
	"glossary" : "enemy", #Unit category I was spawned from
	"spacing" : Vector3(0.6,0,-0.1), #spacing when unit is spawned in battle
}

func _ready() -> void:
	#Debug
	name = str(name," ",randi())
	#Abilities
	var abil = my_component_ability
	abil.my_abilities = [
		abil.ability_tackle.new(self),
		abil.ability_spook.new(self)
	]
	#FUCK this animation tree shit sometimes
	anim_tree.active = true
