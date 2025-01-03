extends Node3D

@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var collider : CollisionShape3D

@export var grid : GridContainer
@export var health : Label
@export var vis : Label

var max_hud_timer : float = 5
var hud_timer : float = 0

func _ready() -> void:
	hide()

func reset_hud_timer():
	hud_timer = max_hud_timer

func _physics_process(delta: float) -> void:
	
	#if !visible:
		#if hud_timer > 0:
			#hud_timer = clamp(hud_timer - 1 * delta,0,max_hud_timer)
			#if !visible:
				#show()
		#elif visible:
			#hide()
	
	if my_component_health:
		health.text = str("♥ ",my_component_health.health,"/",my_component_health.max_health)
	if my_component_vis:
		vis.text = str("◆ ",my_component_vis.vis,"/",my_component_vis.max_vis)
	
func _on_mouse_entered() -> void:
	pass#TODO on-hover information on enemies
func _on_mouse_exited() -> void:
	pass
