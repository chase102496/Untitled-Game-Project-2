class_name component_state_controller_battle
extends component_node

@export var my_component_ability: component_ability

## Used to determine if this character should be waited for before starting next turn
@onready var is_character_ready : bool = true
## Used to go back to whatever previous state we were in
@onready var state_chart_memory : String = ""

func _ready() -> void:
	
	#Animation
	Events.animation_finished.connect(_on_animation_finished)
	Events.animation_started.connect(_on_animation_started)
	
	#Battle
	Events.turn_start.connect(_on_turn_start)
	Events.battle_entity_disabled_expire.connect(_on_battle_entity_disabled_expire)
	Events.battle_team_start.connect(_on_battle_team_start)
	Events.battle_entity_hit.connect(_on_battle_entity_hit)
	Events.battle_entity_damaged.connect(_on_battle_entity_damaged)
	Events.battle_entity_missed.connect(_on_battle_entity_missed)
	Events.battle_entity_turn_end.connect(_on_battle_entity_turn_end)
	Events.battle_entity_death.connect(_on_battle_entity_death)
	#
	%StateChart/Main/Battle/Waiting.state_entered.connect(_on_state_entered_battle_waiting)
	%StateChart/Main/Battle/Start.state_entered.connect(_on_state_entered_battle_start)
	%StateChart/Main/Battle/Choose.state_entered.connect(_on_state_entered_battle_choose)
	%StateChart/Main/Battle/Skillcheck.state_entered.connect(_on_state_entered_battle_skillcheck)
	%StateChart/Main/Battle/Skillcheck.state_exited.connect(_on_state_exited_battle_skillcheck)
	%StateChart/Main/Battle/Execution.state_entered.connect(_on_state_entered_battle_execution)
	%StateChart/Main/Battle/End.state_entered.connect(_on_state_entered_battle_end)
	%StateChart/Main/Battle/End.state_physics_processing.connect(_on_state_physics_processing_battle_end)
	%StateChart/Main/Battle/Dying.state_entered.connect(_on_state_entered_battle_dying)
	%StateChart/Main/Battle/Death.state_entered.connect(_on_state_entered_death)

# SIGNALS

func _on_animation_started(anim_name,character) -> void:
	if character == owner:
		var regex = RegEx.new()
		regex.compile("(default_)(attack|hurt|death)(_.*)?")
		var result = regex.search(anim_name)
		if result:
			match result.get_string(2):
				"attack":
					is_character_ready = false
				"hurt":
					is_character_ready = false
				"death":
					is_character_ready = false
					
func _on_animation_finished(anim_name,character) -> void:
	if character == owner:
		var regex = RegEx.new()
		regex.compile("(default_)(attack|hurt|death)(_.*)?")
		var result = regex.search(anim_name)
		if result: #If result is not null
			match result.get_string(2): #match only 2nd group attack|hurt|death
				"attack":
					if owner.animations.tree.is_attack_final:
						owner.state_chart.send_event("on_end")
				"hurt":
					owner.state_chart.send_event(state_chart_memory) #Statecharts has a bug so I bandaided it
				"death":
					## Once death animation is finished, we are ready to be deleted whenever turn_manager is ready for next turn
					Battle.add_death_queue(owner)

# GLOBAL EVENTS

func _on_battle_team_start(team : String):
	my_component_ability.my_status.status_event("on_battle_team_start",[team])
	if team != owner.alignment:
		my_component_ability.my_status.status_event("on_duration")

func _on_turn_start() -> void: #NOT A STATE CHART, JUST FOR VERY BEGINNING OF TURN
	if Battle.active_character == owner:
		owner.state_chart.send_event("on_start")
	else:
		owner.state_chart.send_event("on_waiting")

func _on_battle_entity_disabled_expire(entity : Node) -> void:
	my_component_ability.my_status.status_event("on_battle_entity_disabled_expire",[entity])

func _on_battle_entity_damaged(entity : Node, amount : int) -> void:
	my_component_ability.my_status.status_event("on_battle_entity_damaged",[entity,amount])

func _on_battle_entity_hit(entity_caster : Node, entity_targets : Array, ability : Object) -> void:
	my_component_ability.my_status.status_event("on_battle_entity_hit",[entity_caster,entity_targets,ability])
	
	if owner == entity_caster: #if we are casting
		entity_caster.my_component_ability.cast_queue.cast_main()
		entity_caster.my_component_ability.cast_queue.fx_cast_main()
	elif owner in entity_targets: #if we're being hit with something
		#run our mitigation, and the 'true' is to return a result so we can tell if anything cares about mitigation in our status
		var query_results = my_component_ability.my_status.status_event("on_ability_mitigation",[entity_caster,owner,ability],true)
		
		if len(query_results) > 0: #If any status effects care about mitigation in general
			
			for i in len(query_results):
				if query_results[i] != Battle.mitigation_type.PASS: #If the ability catches and wants to do something besides pass
					break #exit the loop, it will handle mitigation across the board
				elif i == (len(query_results) - 1): #if we get to the last mitigation in our list because they all passed
					entity_caster.my_component_ability.cast_queue.cast_pre_mitigation(entity_caster,owner)
		else: #means nothing cares and we should pass through as normal
			entity_caster.my_component_ability.cast_queue.cast_pre_mitigation(entity_caster,owner)

func _on_battle_entity_missed(entity_caster : Node, entity_targets : Array, ability : Object):
	my_component_ability.my_status.status_event("on_battle_entity_missed",[entity_caster,entity_targets,ability])
	if entity_caster == owner:
		owner.my_component_ability.cast_queue.cast_validate_failed()

func _on_battle_entity_turn_end(entity : Node):
	my_component_ability.my_status.status_event("on_battle_entity_turn_end",[entity])

func _on_battle_entity_death(entity : Node):
	pass

# STATE EVENTS FOR THIS ENTITY

func _on_state_entered_battle_waiting() -> void:
	is_character_ready = true
	state_chart_memory = "on_waiting"

func _on_state_entered_battle_start() -> void:
	Debug.message("-----------------------",Debug.msg_category.BATTLE)
	Debug.message(["Turn Start: ",owner.name],Debug.msg_category.BATTLE)
	my_component_ability.skillcheck_difficulty = 1.0 #Reset our skillcheck difficulty
	
	my_component_ability.my_status.status_event("on_start")
	owner.state_chart.send_event("on_choose")

func _on_state_entered_battle_choose() -> void:
	
	my_component_ability.my_status.status_event("on_skillcheck")
	
	#Edge case for first battle entity up when loading scene. Needs to wait so abilities and whatnot can be loaded from SceneManager
	if SceneManager.busy:
		await SceneManager.scene_load_end
	
	if my_component_ability.get_abilities().size() == 0:
		push_error("Abilities is empty for unit ", owner.name)
		
	match owner.classification:
		Battle.classification.PLAYER:
			owner.my_battle_gui.state_chart.send_event("on_gui_main")
		Battle.classification.DREAMKIN:
			owner.my_battle_gui.state_chart.send_event("on_gui_main")
		Battle.classification.ENEMY:
			await get_tree().create_timer(0.2).timeout
			
			var ability = my_component_ability.get_abilities().pick_random()
			my_component_ability.cast_queue = ability #Pick random move and assign
			
			var targets = Battle.get_target_type_list(owner,ability.target_type)
			var target = targets.pick_random() #Pick random target based on abil
			
			my_component_ability.cast_queue.targets = Battle.get_target_selector_list(target,ability.target_selector,targets)
			my_component_ability.cast_queue.primary_target = target
			
			owner.state_chart.send_event("on_skillcheck")
			#TODO Check if queued ability is to be used on allies or enemies before choosing
			#turn this into a script we run with battle list as the entire battle field param, and owner as caster
			#the move will narrow down the list of viable targets based on the input and its move type (myteam, enemies, single target, aoe, self, all)
			#the move will then run a script based on whether we are player/dreamkin or enemy and send gui our target array or randomly select from target array
			#eg if x: do x
			#x is single-target, so we either randomly select 1 person from
		_:
			push_error("Not a valid entity for battle: ",owner.name)

func _on_state_entered_battle_skillcheck() -> void:
	match owner.classification:
		Battle.classification.ENEMY: #weighted random skillcheck
			var skillcheck_result = "Miss"
			var skill_rand = randf_range(0,1)/my_component_ability.skillcheck_difficulty #Modify it by skillcheck diff. Higher = smaller num = less good
			if skill_rand >= 0.95:
				skillcheck_result = "Excellent"
			elif skill_rand >= 0.8:
				skillcheck_result = "Great"
			elif skill_rand >= 0.15:
				skillcheck_result = "Good"
				
			my_component_ability.cast_queue.skillcheck(skillcheck_result)
			owner.state_chart.send_event("on_execution")

func _on_state_exited_battle_skillcheck() -> void:
	match owner.classification:
		Battle.classification.PLAYER:
			my_component_ability.cast_queue.skillcheck(owner.my_battle_gui.ui_skillcheck_result) #Modifies our ability based on outcome of skillcheck from ui
		Battle.classification.DREAMKIN:
			my_component_ability.cast_queue.skillcheck(owner.my_battle_gui.ui_skillcheck_result) #Modifies our ability based on outcome of skillcheck from ui
	
func _on_state_entered_battle_execution() -> void:
	my_component_ability.cast_queue.animation()

func _on_state_entered_battle_end() -> void:
	state_chart_memory = "on_end" #For after applying shit we remember where we were
	Events.battle_entity_turn_end.emit(owner) #Let everyone know we're about to end our turn
	my_component_ability.my_status.status_event("on_end") #Including status effects

func _on_state_physics_processing_battle_end(_delta: float) -> void:
	owner.state_chart.send_event("on_waiting")
	Events.turn_end.emit()

func _on_state_entered_battle_dying() -> void:
	is_character_ready = false
	my_component_ability.my_status.status_event("on_dying")
	Events.battle_entity_dying.emit(owner)

func _on_state_entered_death() -> void:
	state_chart_memory = "on_death"
	Events.battle_entity_death.emit(owner)
