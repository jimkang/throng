class_name Collision
extends Node

static func find_colliding_things_at(space_state: PhysicsDirectSpaceState2D, position: Vector2):
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.position = position
	var collision_dicts = space_state.intersect_point(query)
	if collision_dicts.size() < 1:
		return
	else:
		print('collisions: ', collision_dicts.map(func (dict): dict.collider.get_parent()))
		assert(collision_dicts.size() == 1)
		if collision_dicts[0].collider is Area2D:
			var colliding_thing = collision_dicts[0].collider.get_parent()
			return colliding_thing
