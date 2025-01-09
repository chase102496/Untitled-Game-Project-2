extends Node3D

@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var collider : CollisionShape3D

@export var stats : MeshInstance3D
@export var status : MeshInstance3D

@export var grid : GridContainer
@export var health : Label
@export var vis : Label

func _ready() -> void:
	display_stats(false)

func display_stats(val : bool) -> void:
	stats.visible = val

func display_status(val : bool) -> void:
	status.visible = val

func _physics_process(delta: float) -> void:
	if stats.visible:
		if my_component_health:
			health.text = str("♥ ",my_component_health.health,"/",my_component_health.max_health)
		if my_component_vis:
			vis.text = str("◆ ",my_component_vis.vis,"/",my_component_vis.max_vis)
	
func _on_mouse_entered() -> void:
	pass#TODO on-hover information
func _on_mouse_exited() -> void:
	pass
