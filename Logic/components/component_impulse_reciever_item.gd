class_name component_impulse_reciever_item
extends component_impulse_reciever

enum action {
	GIVE,
	TAKE
}

@export var item_action : action = action.GIVE
@export var item : String
@export var quantity : int = 1
@export var args : Array = []

func _ready() -> void:
	super._ready()
	
	if my_impulse and item and item not in Glossary.item_class:
		push_error("Item not found for component_impulse_reciever_item: ",item)

## Will only trigger if our impulse is in one_shot mode, and this makes it permanent in a playthrough
## Good for one-time ability pickups and such
func _on_one_shot() -> void:
	super._on_one_shot()
	_trigger_item()

func _on_activated() -> void:
	super._on_activated()
	print("FUCKING HELL MAN")
	_trigger_item()

func _trigger_item() -> void:
	
	match item_action:
		action.GIVE:
			print("FUCKING HELL MAN 2")
			var inst = Glossary.item_class[item].new.callv([Global.player]+args)
			inst.quantity = quantity
			Global.player.my_component_inventory.add_item(inst)
		action.TAKE:
			Global.player.my_component_inventory.remove_item_id(item,quantity)
			
