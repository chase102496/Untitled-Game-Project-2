class_name component_inventory
extends Node

## --- Inventory Manager ---

var my_items : Array = []

##Placeholder reminder for imports and exports to save file functions!

## Returns all items in the given category
func get_items_category(category_name : Dictionary):
	var result : Array = []
	for item in my_items:
		if item.category == category_name:
			result.append(item)
	return result

#func add_item(inst : Object):
	#for item in my_items:
		#if item.

func remove_item(inst : Object):
	pass

## --- Item Class ---

class item:
	var id : String
	var host : Node
	var category : Dictionary # This is here to sort items by page in our inventory. Gear, Dreamkin, Items, or Keys e.g. Glossary.item_category.GEAR
	var title : String
	var flavor : String # No, not an ice cream flavor kind of flavor. Flavor text, just for fun.
	var description : String
	var sprite : PackedScene #Sprite to be instantiated when item is shown on screen via inventory
	var unstackable : bool = false #If we want it to have its own slot in our inventory
	var quantity : int = 1
	var max_quantity : int = 99
	var options : Dictionary = {} # We need this to get our list of options that we can select for doing something with the item, should be a list of scripts in us
	
	func _init(host : Node) -> void:
		self.host = host
	
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
			"unstackable" : unstackable,
			"quantity" : quantity,
			"max_quantity" : max_quantity,
		}
	
	func get_data():
		return {}
	
	## On increase, usually when we add an item that matches us in the inv
	## Need this to keep track of items internally and avoid overhead on inv manager
	func on_stack(amt : int = 1) -> void:
		if unstackable:
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

## --- Items ---

class item_nectar:
	extends item
	
	var heal_amount
	
	func get_data():
		return {
			"heal_amount" : heal_amount
		}
	
	func _init(host : Node, heal_amount : int = 1, quantity : int = 1) -> void:
		id = "item_nectar"
		title = "Nectar"
		flavor = "You couldn't just call it a health potion?"
		description = "A droplet containing a golden liquid that shimmers like sunlight caught in honey. Looks yummy"
		self.host = host
		self.heal_amount = heal_amount
		self.quantity = quantity
		category = Glossary.item_category.ITEMS
		sprite = Glossary.sprite.placeholder
		
		## List of functions that pop up when we select this item in our inventory. References existing scripts
		options = {
			"use" : on_option_use,
			"remove" : on_remove
		}
	
	## An option displayed in our menu when we click on this item
	## Can literally be named whatever you want
	func on_option_use():
		host.my_component_health.heal(heal_amount)
		#FX GO HERE
		on_consume(1)
