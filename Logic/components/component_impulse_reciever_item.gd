class_name component_impulse_reciever_item
extends component_impulse_reciever

@export var item : String
@export var quantity : int = 1
@export var args : Array = []

func _ready() -> void:
	super._ready()
	if item and item not in Glossary.item_class:
		push_error("Item not found for component_impulse_reciever_item: ",item)

func _on_one_shot() -> void:
	super._on_activated()
	Global.player.my_component_inventory.add_item(Glossary.item_class[item].new.callv([Global.player]+args))
