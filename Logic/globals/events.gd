extends Node

signal battle_gui_button_pressed(ability)

signal animation_finished(anim_name,character)
signal animation_started(anim_name,character)

signal state_chart_ready(character,state_chart_name) #Can use if something is being a BITCH

#Battle signal skeleton
signal turn_end #a fresh turn has started (even before their state on_start)
signal turn_start #a turn has completely ended (even after their state on_end)

signal skillcheck_hit(area,ability_queued) #We just hit our skillcheck animation

#signal battle_entity_cast_failed(entity_caster : Node, entity_target : Node, ability : Object)
#signal battle_entity_hit(entity_caster : Node, entity_target : Node, ability : Object) #someone was hit with an ability
#signal battle_entity_death(entity : Node) #someone died rip
signal battle_entity_damaged(entity : Node, amount : int) #someone took damage

signal battle_finished(result : String)
