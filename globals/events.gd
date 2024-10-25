extends Node

signal turn_end
signal turn_start
signal battle_finished(outcome)
signal battle_gui_button_pressed(ability)
signal animation_finished(anim_name,character)
signal animation_started(anim_name,character)
signal skillcheck_hit(area,ability_queued)
signal state_chart_ready(character,state_chart_name) #Can use if something is being a BITCH
