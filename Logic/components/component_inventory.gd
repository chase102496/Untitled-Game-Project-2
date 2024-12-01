class_name component_inventory
extends Node

## --- Inventory Manager ---

var my_items : Array = []

##Placeholder reminder for imports and exports to save file functions!

## Returns all items in the given category
func get_items_from_category(category_name : Dictionary):
	var result : Array = []
	for item in my_items:
		if item.category == category_name:
			result.append(item)
	return result

func add_item(inst : Object):
	
	## See if matching item exists and both are stackable
	if inst.stackable:
		for item in my_items:
			if item.id == inst.id and item.stackable:
				item.on_stack(inst.quantity)
				return #Exit function
	
	## If we never encounter a match or it's not stackable, just add it normally
	my_items.append(inst)
	

func remove_item(inst : Object):
	my_items.pop_at(my_items.find(inst))

## --- Item Classes ---

class item:
	var id : String
	var host : Node
	var category : Dictionary # This is here to sort items by page in our inventory. Gear, Dreamkin, Items, or Keys e.g. Glossary.item_category.GEAR
	var title : String
	var flavor : String # No, not an ice cream flavor kind of flavor. Flavor text, just for fun.
	var description : String
	var sprite : PackedScene #Sprite to be instantiated when item is shown on screen via inventory
	var stackable : bool = true #If we want it to have its own slot in our inventory
	var quantity : int = 1
	var max_quantity : int = 99
	#var options_world : Dictionary = {} # We need this to get our list of options that we can select for doing something with the item, should be a list of scripts in us
	#var options_battle : Dictionary = {} # We need this to get our list of options that we can select for doing something with the item, should be a list of scripts in us

	enum target_type { # This is how we determine what the item can be used on, for various functions
		PLAYER, SUMMONS, PARTY, ALL
	}
	
	func _init(host : Node) -> void:
		self.host = host
	
	##Return the string names of whatever selections we want, in an array
	func get_choices_display(type : target_type):
		match type:
			target_type.ALL:
				return [Global.player.name] + host.my_component_party.get_hybrid_name_all()
	
	##Return the actual objects of whatever selections we want, in an array
	func get_choices(type : target_type):
		match type:
			target_type.ALL:
				return [Global.player] + host.my_component_party.get_hybrid_data_all()
		
	
	func set_data(new_metadata : Dictionary):
		for key in new_metadata:
			var value = new_metadata[key]
			set(key,value)
	
	func get_data_default():
		return {
			"id" : id,
			"category" : category,
			"title" : title,
			"flavor" : category,
			"description" : description,
			"stackable" : stackable,
			"quantity" : quantity,
			"max_quantity" : max_quantity,
		}
	
	func get_data():
		return {}
	
	## On increase, usually when we add an item that matches us in the inv
	## Need this to keep track of items internally and avoid overhead on inv manager
	func on_stack(amt : int = 1) -> void:
		if !stackable:
			push_error("Attempting to stack an item that shouldn't be stacked")
		else:
			quantity += amt
			quantity = clamp(quantity,0,max_quantity)
	
	## On decrease, usually when we use the item
	## Need this to keep track of items internally and avoid overhead on inv manager
	func on_consume(amt : int = 1) -> void:
		quantity -= amt
		quantity = clamp(quantity,0,max_quantity)
		if quantity <= 0:
			on_remove()
	
	## On depletion, usually when quantity == 0
	## Need this to keep track of items internally and avoid overhead on inv manager
	func on_remove() -> void:
		host.my_component_inventory.remove_item(self)

class item_consumable:
	extends item
	
	## List of functions that pop up in world when we select this item in our inventory. References existing scripts, and their params to grab
	## Legend
	# "choices" is mandatory for each level with a dictionary, and is just a string that leads us in a direction
	# "next" indicates we don't care what we choose, this is the next path forward
	# "branch" will take us on whatever selection we chose, it must match verbatim the choice
	# "choices_params" is an optional parameter that will pass all of its selections to the final script. This must be the same length as "choices" in the same level
	var options_world = {
			"Use" : Callable(self,"on_consume"),
			"Delete" : {
				"choices" : ["Confirm","Cancel"],
				"branch": {
						"Confirm" : Callable(self,"on_consume"),
						"Cancel" : null
				}
			},
			"Delete All" : {
				"choices" : ["Confirm","Cancel"],
				"branch": {
						"Confirm" : Callable(self,"on_remove"),
						"Cancel" : null
				},
			}
		}

## --- Items ---

class item_nectar:
	extends item_consumable
	
	var recovery_amount
	
	func get_data():
		return {
			"recovery_amount" : recovery_amount
		}
	
	func _init(host : Node, recovery_amount : int = 1, quantity : int = 1) -> void:
		id = "item_nectar"
		title = "Nectar"
		flavor = "You couldn't just call it a health potion?"
		description = "A reddish-gold liquid that flows thicker than honey. Best enjoyed near a cozy fire."
		self.host = host
		self.recovery_amount = recovery_amount
		self.quantity = quantity
		category = Glossary.item_category.ITEMS
		sprite = Glossary.sprite.placeholder
		
		options_world["Use"] = {
			"choices" : Callable(self,"get_choices_display").bind(target_type.ALL),
			"choices_params" : Callable(self,"get_choices").bind(target_type.ALL),
			"next" : Callable(self,"on_option_use_world")
		}
	
	## An option displayed in our menu when we click on this item
	## Can literally be named whatever you want
	func on_option_use_world(target : Node = host):
		Interface.change_health(target,recovery_amount)
		#FX GO HERE
		on_consume()
		host.my_inventory_gui.refresh()

class item_dewdrop:
	extends item_consumable

	var recovery_amount
	
	func get_data():
		return {
			"recovery_amount" : recovery_amount
		}
	
	func _init(host : Node, recovery_amount : int = 1, quantity : int = 1) -> void:
		id = "item_dewdrop"
		title = "Dewdrop"
		flavor = "Warning: Staring too long may result in existential crises or sudden nap attacks."
		description = "A silvery droplet that constantly shifts hues, peering inside shows a distant, shimmering painting of something."
		self.host = host
		self.recovery_amount = recovery_amount
		self.quantity = quantity
		category = Glossary.item_category.ITEMS
		sprite = Glossary.sprite.placeholder
		options_world["Use"] = {
			"choices" : Callable(self,"get_choices_display").bind(target_type.ALL),
			"choices_params" : Callable(self,"get_choices").bind(target_type.ALL),
			"next" : Callable(self,"on_option_use_world")
		}
	
	## An option displayed in our menu when we click on this item
	## Can literally be named whatever you want
	func on_option_use_world(target : Node = host):
		Interface.change_vis(target,recovery_amount)
		#FX GO HERE
		on_consume()
		host.my_inventory_gui.refresh()
