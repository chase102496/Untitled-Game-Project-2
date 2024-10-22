extends Node
signal attack_contact

func _ready() -> void:
	pass

func attack_contact_notify():
	attack_contact.emit()
