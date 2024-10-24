extends Node
class_name component_state_controller

@export var my_component_input_controller : component_input_controller
@export var my_component_ability: component_ability

@onready var direction := Vector2.ZERO
@onready var fuckthisshit : bool = true

@onready var character_ready : bool = true

func _ready() -> void:
	Events.turn_start.connect(_on_turn_start)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	#Animation FUCK TODO
	Events.animation_finished.connect(_on_animation_finished)
	Events.animation_started.connect(_on_animation_started)
	
	#Explore
	owner.get_node("StateChart/Main/Explore/Walking").state_physics_processing.connect(_on_state_physics_processing_explore_walking)
	owner.get_node("StateChart/Main/Explore").state_physics_processing.connect(_on_state_physics_processing_explore)
	owner.get_node("StateChart/Main/Explore/Idle").state_physics_processing.connect(_on_state_physics_processing_explore_idle)
	#Battle
	
	owner.get_node("StateChart/Main/Battle/Hurt").state_entered.connect(_on_state_entered_battle_hurt)
	owner.get_node("StateChart/Main/Battle/Hurt").state_physics_processing.connect(_on_state_physics_processing_battle_hurt)
	owner.get_node("StateChart/Main/Battle/Waiting").state_entered.connect(_on_state_entered_battle_waiting)
	owner.get_node("StateChart/Main/Battle/Waiting").state_physics_processing.connect(_on_state_physics_processing_battle_waiting)
	owner.get_node("StateChart/Main/Battle/Start").state_entered.connect(_on_state_entered_battle_start)
	owner.get_node("StateChart/Main/Battle/Choose").state_entered.connect(_on_state_entered_battle_choose)
	owner.get_node("StateChart/Main/Battle/Choose").state_exited.connect(_on_state_exited_battle_choose)
	owner.get_node("StateChart/Main/Battle/Skillcheck").state_entered.connect(_on_state_entered_battle_skillcheck)
	owner.get_node("StateChart/Main/Battle/Skillcheck").state_exited.connect(_on_state_exited_battle_skillcheck)
	owner.get_node("StateChart/Main/Battle/Execution").state_entered.connect(_on_state_entered_battle_execution)
	owner.get_node("StateChart/Main/Battle/Execution").state_physics_processing.connect(_on_state_physics_processing_battle_execution)
	owner.get_node("StateChart/Main/Battle/End").state_physics_processing.connect(_on_state_physics_processing_battle_end)
	#Death
	owner.get_node("StateChart/Main/Battle/Death").state_entered.connect(_on_state_entered_death)
	
func _physics_process(_delta: float) -> void:
	if my_component_input_controller:
		direction = my_component_input_controller.direction
	
	#FIXME bandaid
	if owner.state_init_override:
		owner.state_chart.send_event(owner.state_init_override)
		owner.state_init_override = null

#Explore
func _on_state_physics_processing_explore(_delta: float) -> void:
	pass
func _on_state_physics_processing_explore_idle(_delta: float) -> void:
	if direction != Vector2.ZERO:
		owner.state_chart.send_event("on_walking")
func _on_state_physics_processing_explore_walking(_delta: float) -> void:
	if direction == Vector2.ZERO:
		owner.state_chart.send_event("on_idle")

#Battle

func _on_animation_started(anim_name,character):
	print(anim_name,character)
	if character == owner:
		match anim_name:
			"default_attack":
				print(anim_name," START")
				character_ready = false
			"default_hurt":
				print(anim_name," START")
				character_ready = false
			"default_death":
				print(anim_name," START")
				character_ready = false

func _on_animation_finished(anim_name,character):
	if character == owner:
		match anim_name:
			"default_attack":
				print(anim_name," END")
				owner.state_chart.send_event("on_end")
			"default_hurt":
				print(anim_name," END")
				owner.state_chart.send_event("on_waiting")
			"default_death":
				print(anim_name," END")
				Battle.battle_list.pop_at(Battle.battle_list.find(owner,0)) #remove us from queue
				#Check if we are the last one
				if len(Battle.get_team("foes")) == 0: #TODO Make an end battle screen? Nah actually
					Events.battle_finished.emit("Win")
				elif len(Battle.get_team("friends")) == 0:
					Events.battle_finished.emit("Lose")
				elif Battle.active_character == owner:
					Events.turn_end.emit() #FIXME EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
				owner.queue_free() #deletus da fetus

func _on_turn_start(): #NOT A STATE CHART, JUST FOR VERY BEGINNING OF TURN
	if Battle.active_character == owner:
		owner.state_chart.send_event("on_start")
		owner.state_init_override = "on_start" #FUCK this state machine sometimes
	else:
		owner.state_chart.send_event("on_waiting")
	pass

func _on_state_entered_battle_waiting():
	character_ready = true
func _on_state_physics_processing_battle_waiting(_delta: float) -> void:
	pass

func _on_state_entered_battle_start():
	print_debug("-----------------------")
	print_debug("Turn Start: ",owner.name)
	owner.state_chart.send_event("on_choose") #TODO Add something here later for initializing battle
	#TODO check if it's our turn, and if it is, run start conditions like
	# setting stats or whatever if we have a boost like certain pokemon
	# If this is the first round of turns (we will check and keep track with var), skip choose and skillcheck
	if !owner.sprite.attack_contact.is_connected(_on_attack_contact):
		owner.sprite.attack_contact.connect(_on_attack_contact) #For informing us when to hit target with cast()
	
	
func _on_state_entered_battle_choose():
	match owner.stats.glossary:
		"player":
			owner.my_battle_gui.state_chart.send_event("on_gui_main")
		"enemy":
			await get_tree().create_timer(0.5).timeout
			owner.my_component_ability.cast_queue =  owner.my_component_ability.my_abilities.pick_random() #Pick random move
			
			#TODO Check if queued ability is to be used on allies or enemies before choosing
			owner.my_component_ability.cast_queue.target = Battle.get_team("friends").pick_random()
			
			var skillcheck_result = "Miss"
			var skill_rand = randf_range(0,1)
			if skill_rand >= 0.95:
				skillcheck_result = "Excellent"
			elif skill_rand >= 0.8:
				skillcheck_result = "Great"
			elif skill_rand >= 0.25:
				skillcheck_result = "Good"
				
			owner.my_component_ability.cast_queue.skillcheck(skillcheck_result) #Pick random skillcheck value
			owner.state_chart.send_event("on_execution")
		_:
			push_error("Not a valid entity for battle: ",owner.name)
func _on_state_exited_battle_choose():
	pass

func _on_state_entered_battle_skillcheck():
	pass
func _on_state_exited_battle_skillcheck():
	owner.my_component_ability.cast_queue.skillcheck(owner.my_battle_gui.ui_skillcheck_result) #Modifies our ability based on outcome of skillcheck from ui
	owner.state_chart.send_event("on_execution")
	
func _on_state_entered_battle_execution():
	owner.my_component_ability.cast_queue.animation()
func _on_state_physics_processing_battle_execution(_delta: float) -> void:
	pass
func _on_attack_contact():
	owner.my_component_ability.cast_queue.cast()

func _on_state_physics_processing_battle_end(_delta: float) -> void:
	#End code goes here, then we ready up
	if Battle.check_ready():
		owner.state_chart.send_event("on_waiting")
		Events.turn_end.emit()
	character_ready = true
	
	# setting stats or whatever if we have a boost like certain pokemon after attacking
	# can also be checking for things that affect us when we hit enemy

func _on_state_entered_battle_hurt():
	
	owner.anim_tree.get("parameters/playback").travel("Hurt")
func _on_state_physics_processing_battle_hurt(_delta: float) -> void:
	pass

func _on_state_entered_death():
	owner.anim_tree.get("parameters/playback").travel("Death")

#Dialogic signals
func _on_dialogic_signal(arg : String) -> void:
	#pass on the string from dialogue signal to state machine
	owner.state_chart.send_event(arg)
