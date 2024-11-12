class_name cinderling
extends enemy

func _ready() -> void:
	name = str(name," ",randi_range(0,99))
	var abil = my_component_ability
	abil.my_abilities.append(abil.ability_solar_flare.new(self,2,0.3,0))
	abil.current_status_effects.add_passive(abil.status_immunity.new(self,Battle.type.NOVA))
