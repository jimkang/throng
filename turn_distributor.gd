class_name TurnDistributor
extends Node

func _unhandled_key_input(event):
	# Don't handle press events. Throngs don't expect them, and when you do
	# handle them, throngs ignore them, but free individuals get an extra turn.
	if not event.is_action_type() or not event.is_released():
		return

	print('input received')
	var throngs = get_tree().get_nodes_in_group('throngs')
	throngs.sort_custom(Hierarchy.compare_init)
	print('Giving turns to throngs: ', throngs)
	for throng in throngs:
		# Sync the physics in case something moved so that the next throng
		# has an accurate physics situation to work with.
		await get_tree().physics_frame
		await throng.take_turn(event)
	var free_indivs = get_tree().get_nodes_in_group('individuals')
	free_indivs.sort_custom(Hierarchy.compare_init)	
	print('Giving turns to free individuals: ', free_indivs.map(func(indiv): return indiv.readable_name))

	for individual in free_indivs:
		# We can't assume an individual will be there because an
		# individual taking a &turn means another individual may die and be gone.
		if individual == null:
			continue
		# Sync the physics in case something moved so that the next individual
		# has an accurate physics situation to work with.
		await get_tree().physics_frame
		await individual.take_turn(event)
	await $'../sprite_presenter'.sync_presentation()	
