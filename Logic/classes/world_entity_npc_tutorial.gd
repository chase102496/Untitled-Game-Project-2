class_name world_entity_npc_tutorial
extends world_entity_npc_default

func _on_interact() -> void:
	Dialogic.start("timeline")
