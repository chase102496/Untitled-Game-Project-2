extends Label3D

@export var my_component_state_controller_battle : component_state_controller_battle
@export var my_component_health : component_health
@export var my_component_vis : component_vis

@onready var prev = "init"
@onready var history = "history"
@onready var state_subchart_battle

func _ready() -> void:
	state_subchart_battle = owner.get_node("StateChart/Main/Battle")
	#position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug"):
		if visible:
			hide()
		else:
			show()
	
	var state = str(state_subchart_battle._active_state)
	
	if prev != state:
		history = prev
		prev = state

	text = str(my_component_state_controller_battle.character_ready,
	"\n",
	owner.name,
	"\n",
	"HP: ",my_component_health.health,"/",my_component_health.max_health,
	"\n",
	"MP: ",my_component_vis.vis,"/",my_component_vis.max_vis,
	"\n",
	"Now: ", state.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
