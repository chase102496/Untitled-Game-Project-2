extends Area3D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area : Area3D) -> void:
	#print(area)
	pass