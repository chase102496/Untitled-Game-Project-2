extends Node

@warning_ignore("shadowed_global_identifier")
func simple_print(str):
	print(str)

func test_ability(caster, target, dmg):
	print("doot doot, I shall cast dooty doot",", I am going to steal ",dmg," from ",caster)
	target.stats.health -= dmg
	caster.stats.health += dmg
	
	#tell caster what animation to play, and tell target what animation to play based on a type that everyone will have
	#Examples,
	# for caster: ranged_throwing, ranged_magic_small, ranged_magic_special
	# for target: hit_small, hit_big, hit_status_effect
	
func click_of_death(caster, target):
	caster.anim_tree.get("parameters/playback").travel("Death")
	await caster.anim_tree.animation_finished
	target.anim_tree.get("parameters/playback").travel("Death")
	await target.anim_tree.animation_finished
	get_tree().quit()
