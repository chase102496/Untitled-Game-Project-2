extends Control

@export var prompt_label : Label

func _ready():
	update_pivot()
	%prompt_label.resized.connect(_on_resized)

func update_pivot():
	pivot_offset = size / 2

	# If the text changes dynamically, ensure to call `update_pivot`
func _on_resized():
	update_pivot()
