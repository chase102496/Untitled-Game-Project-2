extends Label3D

var enabled : bool = true
@onready var prev = "init"
@onready var history = "history"

func _ready() -> void:
	#position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug"):
		if visible:
			hide()
		else:
			show()
	
	var state = str(owner.state_subchart_battle._active_state)
	
	if prev != state:
		history = prev
		prev = state

	text = str(owner.my_component_state_controller_battle.character_ready,
	"\n",
	owner.name,
	"\n",
	owner.my_component_health.health,"/",owner.my_component_health.max_health,
	"\n",
	"Now: ", state.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
