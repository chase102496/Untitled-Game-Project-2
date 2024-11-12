class_name core_warden
extends enemy

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_tackle.new(self))
	abil.current_status_effects.add_passive(abil.status_ethereal.new(self,Battle.type.TETHER))
