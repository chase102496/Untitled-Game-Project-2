extends Marker2D
#Init
var active_character := Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Sprite2D.material.set_shader_parameter("thickness", 0)
	
	Events.turn_start.connect(_on_turn_start)
	Events.turn_end.connect(_on_turn_end)

func _on_turn_start(start_character) -> void:
	if start_character == self:
		$Sprite2D.material.set_shader_parameter("thickness", 5)
	active_character = start_character
	
func _on_turn_end(_end_character):
	$Sprite2D.material.set_shader_parameter("thickness", 0)
	pass

func _process(_delta: float) -> void:
	pass
	
