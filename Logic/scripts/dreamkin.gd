extends CharacterBody3D

#Battle entity
@onready var my_component_health: component_health = %Components/component_health
@onready var my_component_vis: component_vis = %Components/component_vis
@onready var my_component_ability: component_ability = %Components/component_ability
@onready var my_component_status: component_status = %Components/component_status
@onready var my_component_state_controller_battle: component_state_controller_battle = %Components/component_state_controller_battle

#Statecharts
@onready var state_chart: StateChart = %StateChart
@onready var state_subchart_battle := %StateChart/Main/Battle
@onready var state_init_override = null
#Animations
@export var animations : Node3D
#Status HUD
@onready var status_hud : Node3D = %Status_HUD
#Player or Dreamkin
@onready var my_component_input_controller: component_input_controller_follow = %Components/component_input_controller_follow
@onready var my_battle_gui : Control = %Battle_GUI

var stats : Dictionary = {
	"alignment" : Battle.alignment.FRIENDS, #Side of the field I will fight on
	"glossary" : "dreamkin", #Unit category I was spawned from
	"spacing" : Vector3(0.9,0,-0.1), #spacing when unit is spawned in battle
}
