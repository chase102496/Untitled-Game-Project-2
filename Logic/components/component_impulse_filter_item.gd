## This will listen for the inputs under my_impulse, and when they are all activated, it will send its own impulse
class_name component_impulse_filter_item
extends component_impulse_filter

@export var item_id : String
@export var quantity : int = 1

func _ready() -> void:
	super._ready()

func _on_my_impulse_activated() -> void:
	super._on_my_impulse_activated()
	if Global.player.my_component_inventory.has_item_id(item_id):
		if Global.player.my_component_inventory.get_item_id(item_id).quantity >= quantity:
			activated.emit()

func _on_my_impulse_deactivated() -> void:
	super._on_my_impulse_deactivated()
	deactivated.emit()
