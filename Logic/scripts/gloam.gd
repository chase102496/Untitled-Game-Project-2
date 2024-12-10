extends Area3D

@export var strength : int = 1

var target : Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body : Node3D):
	
	if body.get("loomlight"): #Check if target has a loomlight
		target = body
	
		#
		#var dir = body.velocity.normalized()
		#dir.y = 0
		#body.state_chart.send_event("on_disabled")
		#
		#body.velocity = Vector3.ZERO
		#var tween_inst = create_tween()
		#tween_inst.tween_property(body,"velocity",8*-dir,0.3)
		#
		#await get_tree().create_timer(0.4).timeout
		#
		#body.state_chart.send_event("on_enabled")

func _on_body_exited(body : Node3D):
	target = null

func _physics_process(delta: float) -> void:
	if target:
		target.loomlight.change_gleam(-strength*delta)
