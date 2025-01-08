extends Node

signal entity_health_changed(entity : Node, amt : int)
signal entity_vis_changed(entity : Node, amt : int)

## --- GUI ---

signal button_pressed_echoes_ability(ability : Object)
signal button_pressed_inventory_item(item : Object)
signal mouse_entered_inventory_item(item : Object)
signal mouse_exited_inventory_item(item : Object)

signal button_pressed_switch_dreamkin(dreamkin : Object)

signal button_pressed_inventory_item_option(item : Object, option_path : Array, choices_path : Array)

## --- Animations ---

signal animation_finished(anim_name,character)
signal animation_started(anim_name,character)

## --- State charts, not in use rn I think

signal state_chart_ready(character,state_chart_name) #Can use if something is being a BITCH

## --- Battle Signals

signal turn_end #a fresh turn has started (even before their state on_start)
signal turn_start #a turn has completely ended (even after their state on_end)

signal skillcheck_hit(area,ability_queued) #We just hit our skillcheck animation

signal battle_team_start(team : String) #When a team has started their turn

signal battle_entity_disabled_expire(entity : Node) #When an entity came out of a disable

signal battle_entity_turn_end(entity : Node)
signal battle_entity_missed(entity_caster : Node, entity_targets : Array, ability : Object)
signal battle_entity_hit(entity_caster : Node, entity_targets : Array, ability : Object) #someone was hit with an ability
signal battle_entity_damaged(entity : Node, amount : int,type : String) #someone took damage
signal battle_entity_death(entity : Node) #someone died rip

signal battle_finished(result : String)
