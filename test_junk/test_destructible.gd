extends StaticBody3D

func _ready() -> void:
	$"../Monitor".body_impacted.connect(_on_body_impacted)

func _on_body_impacted(body : Node3D, vel : Vector3):
	
	set_collision_layer_value(1,false)
	Global.create_hitstop(0.025)
	
	await get_tree().create_timer(1).timeout
	
	set_collision_layer_value(1,true)
