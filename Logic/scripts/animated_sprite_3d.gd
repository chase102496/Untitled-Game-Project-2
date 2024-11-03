extends Node
signal attack_contact

func _ready() -> void:
	pass

func attack_contact_notify():
	attack_contact.emit()

#Is my sprite relative to the camera flat? In either direction
