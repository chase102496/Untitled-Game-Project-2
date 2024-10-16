extends Node3D
#Init
var active_character := Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#TODO set up for AnimatedSprite3D
	$Turn_Sprite3D.material_override.set_shader_parameter("glowDensity", 0)
	
	Events.turn_start.connect(_on_turn_start)
	Events.turn_end.connect(_on_turn_end)

func _on_turn_start(start_character) -> void:
	active_character = start_character
	if active_character == self:
		print(self.name)
		$Turn_Sprite3D.material_override.set_shader_parameter("glowDensity", 10)
	
func _on_turn_end(_end_character):
	$Turn_Sprite3D.material_override.set_shader_parameter("glowDensity", 0)

func _process(_delta: float) -> void:
	pass
