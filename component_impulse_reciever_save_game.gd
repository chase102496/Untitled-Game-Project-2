class_name component_impulse_reciever_save_game
extends component_impulse_reciever

func _on_activated() -> void:
	super._on_activated()
	SaveManager.save_data_persistent()
