@icon("res://Art/icons/node icons/node/icon_bag.png")

class_name component_inventory
extends component_node

## --- Inventory Manager ---

var my_inventory : Array = []

##Placeholder reminder for imports and exports to save file functions!

## SAVE
func get_data_inventory_all():
	var result : Array = []
	for item in my_inventory:
		
		var sub_result : Dictionary = {}
		sub_result = item.get_data_default() #Set default vars
		sub_result.merge(item.get_data(),true) #Include and overwrite any defaults like id, etc
		result.append(sub_result) #Append this merged data to our entry in the array
			
	return result

## LOAD
func set_data_inventory_all(host : Node, inventory_data_list : Array):
	my_inventory = [] ## IMPORTANT NOTE HERE, IT OVERWRITES WHATEVER INVENTORY WE HAD NO MATTER WHAT IF THIS IS UNCOMMENTED
	for item in inventory_data_list:
	
		var inst = Glossary.item_class[item["id"]].new.callv([host]+item.args)
	
		inst.set_data(item)
		add_item(inst)

## Returns all items in the given category
func get_items_from_category(category_title : String) -> Array:
	var result : Array = []
	for item in my_inventory:
		if item.category.TITLE == category_title:
			result.append(item)
	return result

### Returns all items that can be used in battle
#func get_items_for_battle():
	#var result : Array = []
	#for item in my_inventory:
		#pass

func add_item(inst : Object):
	
	## See if matching item exists and both are stackable
	if inst.stackable:
		for item in my_inventory:
			if item.id == inst.id and item.stackable:
				item.on_stack(inst.quantity)
				return
	
	## If we never encounter a match or it's not stackable, just add it normally
	my_inventory.append(inst)

func remove_item(inst : Object):
	my_inventory.pop_at(my_inventory.find(inst))

## --- Item Classes ---

class item:
	extends save_object
	
	var id : String
	var classification : String = Battle.classification.ITEM
	
	var host : Node
	var category : Dictionary # This is here to sort items by page in our inventory. Gear, Dreamkin, Items, or Keys e.g. Glossary.item_category.GEAR
	var title : String
	var flavor : String # No, not an ice cream flavor kind of flavor. Flavor text, just for fun.
	var description : String
	
	## Icon to be instantiated when item is shown on screen via inventory
	var icon : PackedScene = Glossary.icon_random.pick_random()
	
	## If we want it to have its own slot in our inventory
	var stackable : bool
	var quantity : int = 1
	var max_quantity : int = 99
	var options_world : Dictionary = {} # We need this to get our list of options that we can select for doing something with the item, should be a list of scripts in us
	var options_battle : Dictionary = {} # We need this to get our list of options that we can select for doing something with the item, should be a list of scripts in us
	## This represents what it will look like when in the player's inventory
	
	enum target_type { # This is how we determine what the item can be used on, for various functions
		PLAYER, SUMMONS, PARTY, ALL
	}
	
	func _init(host : Node) -> void:
		self.host = host
	
	func set_data(new_metadata : Dictionary):
		for key in new_metadata:
			var value = new_metadata[key]
			set(key,value)
	
	func get_data() -> Dictionary:
		return {}
	
	func get_data_default() -> Dictionary:
		return {
			"id" : id,
			"valid_worlds_load" : valid_worlds_load,
			"valid_worlds_save" : valid_worlds_save,
			"category" : category,
			"title" : title,
			"flavor" : category,
			"icon" : icon,
			"description" : description,
			"stackable" : stackable,
			"quantity" : quantity,
			"max_quantity" : max_quantity,
			"args" : [],
			#"options_world" : options_world, TODO if we want this to be per-object not per-class
			#"options_battle" : options_battle,
		}

	##Return the string names of whatever selections we want, in an array
	func get_choices_display(type : target_type) -> Array:
		match type:
			target_type.ALL:
				return [Global.player.display_name] + host.my_component_party.get_hybrid_name_all()
			_:
				push_error("Unknown type for get_choices - ",type)
				return []
	
	##Return the actual objects of whatever selections we want, in an array
	func get_choices(type : target_type) -> Array:
		match type:
			target_type.ALL:
				return [Global.player] + host.my_component_party.get_hybrid_data_all()
			_:
				push_error("Unknown type for get_choices - ",type)
				return []
	
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

class item_echo:
	extends item
	
	var my_world_ability : RefCounted
	var my_world_ability_id : String
	var is_equipped : bool
	
	func get_data():
		return {
			## Args that come after host and are mandatory
			"args" : [my_world_ability_id],
			"is_equipped" : is_equipped
		}
	
	## This is some fucking black magic head fuckery
	func _init(host : Node, my_world_ability_id : String) -> void:
		super._init(host)
		self.my_world_ability_id = my_world_ability_id
		
		## Exception for battle. We only want load the world_ability in world
		if Global.get_current_scene_type() == Global.scene_type.WORLD:
			my_world_ability = Glossary.world_ability_class[my_world_ability_id].new(host)
			icon = my_world_ability.icon
			title = my_world_ability.title
			
		id = "item_echo"
		flavor = "No flavor. Like your step-mom makes"
		description = "No description. Like that criminal that got away"
		stackable = false
		category = Glossary.item_category.GEAR
		options_world = {
			"Equip" : Callable(self,"on_equip_change"),
		}
	
	func _equip() -> void:
		is_equipped = true
	
	func _unequip() -> void:
		is_equipped = false
	
	func on_equip_change() -> void:
		if my_world_ability.is_in_equipment():
			host.my_component_world_ability.unset_equipment(my_world_ability)
			_unequip()
		else:
			host.my_component_world_ability.set_equipment(my_world_ability)
			_equip()

## --- Items ---

class item_consumable:
	extends item
	
	func _init(host : Node) -> void:
		stackable = true
		
		## List of functions that pop up in world when we select this item in our inventory. References existing scripts, and their params to grab
		## Legend
		# "next" indicates we don't care what we choose, this is the next path forward
		# "branch" will take us on whatever selection we chose, it must match verbatim the choice
		# "choices" is mandatory for each level with a dictionary, and is just a string that leads us in a direction
		# "choices_params" is an optional parameter that will pass all of its selections to the final script. This must be the same length as "choices" in the same level
		# "choices_info" is optional info passed to the button display to display additional info like health, item descriptions, etc.
		options_world["Use"] = {
			"choices" : Callable(self,"get_choices_display").bind(target_type.ALL),
			"choices_info" : Callable(self,"get_choices").bind(target_type.ALL),
			"choices_params" : Callable(self,"get_choices").bind(target_type.ALL),
			"next" : Callable(self,"on_option_use_world")
		}
		options_battle["Use"] = {
			"choices" : Callable(self,"get_choices_display").bind(target_type.ALL),
			"choices_info" : Callable(self,"get_choices").bind(target_type.ALL),
			"choices_params" : Callable(self,"get_choices").bind(target_type.ALL),
			"next" : Callable(self,"on_option_use_battle")
		}
		options_world["Delete"] = {
				"choices" : ["Confirm","Cancel"],
				"branch": {
						"Confirm" : Callable(self,"on_consume"),
						"Cancel" : null
				}
		}
		options_world["Delete All"] = {
				"choices" : ["Confirm","Cancel"],
				"branch": {
						"Confirm" : Callable(self,"on_remove"),
						"Cancel" : null
				}
		}

class item_nectar:
	extends item_consumable
	
	var recovery_amount
	
	func get_data():
		return {
			"recovery_amount" : recovery_amount
		}
	
	func _init(host : Node, recovery_amount : int = 1, quantity : int = 1) -> void:
		super._init(host)
		id = "item_nectar"
		title = "Nectar"
		flavor = "You couldn't just call it a health potion?"
		description = "A reddish-gold liquid that flows thicker than honey. Best enjoyed near a cozy fire."
		icon = Glossary.icon_scene["heart"]
		self.host = host
		self.recovery_amount = recovery_amount
		self.quantity = quantity
		category = Glossary.item_category.ITEMS
	
	func on_option_verify(target) -> bool:
		var my_component_health = Interface.get_root_health(target)
		return my_component_health.health != my_component_health.max_health
	
	## An option displayed in our menu when we click on this item
	## Can literally be named whatever you want
	func on_option_use_world(target = host) -> bool:
		if on_option_verify(target):
			Interface.change_health(target,recovery_amount)
			on_consume()
			## FX GO HERE
			Battle.active_character.state_chart.send_event("on_end")
		
		return on_option_verify(target)
	
	func on_option_use_battle(target = host) -> bool:
		if on_option_verify(target):
			Interface.change_health(target,recovery_amount)
			on_consume()
			## FX GO HERE
			Battle.active_character.state_chart.send_event("on_end")
		
		return on_option_verify(target)

class item_dewdrop:
	extends item_consumable

	var recovery_amount
	
	func get_data():
		return {
			"recovery_amount" : recovery_amount
		}
	
	func _init(host : Node, recovery_amount : int = 1, quantity : int = 1) -> void:
		super._init(host)
		id = "item_dewdrop"
		title = "Dewdrop"
		flavor = "Warning: Staring too long may result in existential crises or sudden nap attacks."
		description = "A silvery droplet that constantly shifts hues, peering inside shows a distant, shimmering painting of something."
		icon = Glossary.icon_scene["vis"]
		self.host = host
		self.recovery_amount = recovery_amount
		self.quantity = quantity
		category = Glossary.item_category.ITEMS
	
	func on_option_verify(target) -> bool:
		var my_component_vis = Interface.get_root_vis(target)
		return my_component_vis.vis != my_component_vis.max_vis
	
	## An option displayed in our menu when we click on this item
	## Can literally be named whatever you want
	func on_option_use_world(target = host) -> bool:
		if on_option_verify(target):
			Interface.change_vis(target,recovery_amount)
			on_consume()
			## FX GO HERE
			Battle.active_character.state_chart.send_event("on_end")
		
		return on_option_verify(target)
	
	func on_option_use_battle(target = host) -> bool:
		if on_option_verify(target):
			Interface.change_vis(target,recovery_amount)
			on_consume()
			## FX GO HERE
			Battle.active_character.state_chart.send_event("on_end")
		
		return on_option_verify(target)
