class_name component_inventory
extends Node

class item:
	var category : Dictionary
	var title : String
	var description : String
	var sprite : Sprite2D
	var quantity : int # -1 for unstackable

	func _init() -> void:
		pass
#Types of items
