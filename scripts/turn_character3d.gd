extends Node3D
#Init

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#TODO set up for AnimatedSprite3D
	#$AnimatedSprite3D.material_override.set_shader_parameter("glowDensity", 0)
	
	#Events.turn_start.connect(_on_turn_start)
	#Events.turn_end.connect(_on_turn_end) #TODO TEMPORARY, THE UNIT ITSELF WILL LET US KNOW WHEN ITS TURN IS OVER NOT THE MANAGER

func _on_turn_start() -> void:
	pass
	#if Battle.active_character == self:
		#print("TURN: ",self.name)
		#$AnimatedSprite3D.material_override.set_shader_parameter("glowDensity", 10)

func _on_turn_end():
	#$AnimatedSprite3D.material_override.set_shader_parameter("glowDensity", 0)
	pass

func _process(_delta: float) -> void:
	pass
