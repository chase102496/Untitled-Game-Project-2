extends Node3D

var range : int

var light_strength : float = 2

@onready var area = $Area3D
@onready var fog = $FogVolume
@onready var light = $OmniLight3D
@onready var state_chart = $StateChart

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	
	$StateChart/Main/Disabled.state_entered.connect(_on_state_entered_disabled)
	$StateChart/Main/Enabled.state_entered.connect(_on_state_entered_enabled)

func _on_area_entered(area : Area3D):
	state_chart.send_event("on_enabled")

func _on_area_exited(area : Area3D):
	state_chart.send_event("on_disabled")
	

func set_range(amt : int):
	range = amt
	update_range()

func update_range():
	scale = Vector3(range,range,range)

func _on_state_entered_enabled() -> void:
	print_debug("ENABLED")
	
	show()
	var tween_inst = get_tree().create_tween()
	tween_inst.tween_property(light,"light_energy",light_strength,1)

func _on_state_entered_disabled() -> void:
	print_debug("DISABLED")
	
	var tween_inst = get_tree().create_tween()
	tween_inst.tween_property(light,"light_energy",0,1)
	await tween_inst.finished
	hide()
