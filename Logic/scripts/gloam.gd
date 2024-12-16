extends Node3D

@onready var my_area : Area3D = $Area3D
@onready var my_body : StaticBody3D = $StaticBody3D
@onready var my_fog : FogVolume = $FogVolume

func _ready() -> void:
	my_area.body_entered.connect(_on_body_entered)
	my_area.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body : Node3D):
	pass

func _on_body_exited(body : Node3D):
	pass
