## Attach this component and then specify which values you want to toggle for activated and deactivated in export
@icon("res://Art/icons/node icons/node/icon_square.png")
class_name component_impulse_filter_relay
extends component_impulse_filter

func _on_my_impulse_activated() -> void:
	super._on_my_impulse_activated()
	_on_activated.call_deferred()

func _on_my_impulse_deactivated() -> void:
	super._on_my_impulse_deactivated()
	_on_deactivated.call_deferred()

##
#
#func _on_my_impulse_activated_load() -> void:
	#super._on_my_impulse_activated_load()
	#_on_activated_load()
#
#func _on_my_impulse_deactivated_load() -> void:
	#super._on_my_impulse_deactivated_load()
	#_on_deactivated_load()
