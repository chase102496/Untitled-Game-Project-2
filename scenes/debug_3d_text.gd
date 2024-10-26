extends Label3D

@onready var prev = "init"
@onready var history = "history"

func _ready() -> void:
	position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))

func _physics_process(delta: float) -> void:
	var state = str(owner.state_subchart_battle._active_state)
	
	if prev != state:
		history = prev
		prev = state

	text = str(owner.my_component_state_controller.character_ready,
	"\n",
	owner.name,
	"\n",
	"Now: ", state.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
