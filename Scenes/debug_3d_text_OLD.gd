extends Label3D

@export var my_component_state_controller_battle : component_state_controller_battle
@export var my_component_health : component_health
@export var my_component_vis : component_vis
@export var my_component_ability : component_ability 

@onready var prev = "init"
@onready var history = "history"
@onready var state_subchart_battle

func _ready() -> void:
	state_subchart_battle = owner.get_node("StateChart/Main/Battle")
	#position.y += randf_range(0,0.6)
	modulate = Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1))

func _physics_process(delta: float) -> void:
	
	var state = str(state_subchart_battle._active_state)
	
	if prev != state:
		history = prev
		prev = state
	
	var passive_effects_display : Array = []
	var status_effects_display : Array = ["","",""]
	var status_manager = my_component_ability.my_status
	
	if status_manager.NORMAL:
		status_effects_display[0] = status_manager.NORMAL.title
	if status_manager.TETHER:
		status_effects_display[1] = status_manager.TETHER.title

	for i in len(status_manager.PASSIVE):
		passive_effects_display.append(status_manager.PASSIVE[i].title)
	
	var abil = owner.my_component_ability.get_data_ability_all()
	var abil_names : Array = []
	
	for i in abil.size():
		abil_names.append(abil[i].title)
	
	text = str(
	owner.name,
	"\n",
	my_component_state_controller_battle.character_ready,
	"\n",
	abil_names,
	"\n",
	"Status: ",status_effects_display,
	"\n",
	"Passive: ",passive_effects_display,
	"\n",
	"HP: ",my_component_health.health,"/",my_component_health.max_health,
	"\n",
	"MP: ",my_component_vis.vis,"/",my_component_vis.max_vis,
	"\n",
	"Now: ", state.rsplit(":")[0],
	"\n",
	"Prev: ", history.rsplit(":")[0])
