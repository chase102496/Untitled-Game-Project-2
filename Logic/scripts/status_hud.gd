extends Node3D

@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var collider : CollisionShape3D

@onready var grid : GridContainer = $SubViewport/PanelContainer/VBoxContainer/status_grid
@onready var health : Label = $SubViewport/PanelContainer/VBoxContainer/Health
@onready var vis : Label = $SubViewport/PanelContainer/VBoxContainer/Vis

var max_hud_timer : float = 5
var hud_timer : float = 0

func _ready() -> void:
	hide()
	owner.mouse_entered.connect(_on_mouse_entered)
	owner.mouse_exited.connect(_on_mouse_exited)

func reset_hud_timer():
	hud_timer = max_hud_timer

func _physics_process(delta: float) -> void:
	
	if hud_timer > 0:
		hud_timer = clamp(hud_timer - 1 * delta,0,max_hud_timer)
		if !visible:
			show()
	elif visible:
		hide()
	
	if my_component_health:
		health.text = str("♥ ",my_component_health.health,"/",my_component_health.max_health)
	if my_component_vis:
		vis.text = str("◆ ",my_component_vis.vis,"/",my_component_vis.max_vis)
	
func _on_mouse_entered() -> void:
	pass#TODO on-hover information on enemies
func _on_mouse_exited() -> void:
	pass
