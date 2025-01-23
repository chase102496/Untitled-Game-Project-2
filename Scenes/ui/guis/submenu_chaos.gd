extends Control

func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)

func _on_child_entered_tree(node : Node) -> void:
	
	print(get_children())
