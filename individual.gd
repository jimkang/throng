class_name Individual
extends Node2D

@export var color_set: PackedColorArray

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = color_set[randi_range(0, color_set.size()-1)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Returns true if we were actually able to move.
func move(move_vector: Vector2, result_array: Array):
	var next_pos = self.position + move_vector
	var tilemap: TileMap = self.get_node('/root/throng_root_node/dungeon_tilemap')
	var next_cell_pos = tilemap.local_to_map(tilemap.to_local(next_pos))
	print('next_cell_pos: ', next_cell_pos)
	var dest_cell_data = tilemap.get_cell_tile_data(0, next_cell_pos)
	var result = false
	if dest_cell_data:
		var is_floor = dest_cell_data.get_custom_data('is_floor')		
		if is_floor:
			var space_state = get_world_2d().direct_space_state
			var query := PhysicsPointQueryParameters2D.new()
			query.collide_with_areas = true
			query.position = next_pos
			var collision_dicts = space_state.intersect_point(query)
			#print('collision_dicts', collision_dicts)
			var self_throng_id = self.get_throng_id()
			if self_throng_id:
				if collision_dicts.size() < 1:
					self.position += move_vector
					result = true
				else:
					assert(collision_dicts.size() == 1)
					if collision_dicts[0].collider is Area2D:
						var colliding_thing = collision_dicts[0].collider.get_parent()
						print('would collide with', colliding_thing)
						if colliding_thing.get_meta('individual'):
							# TODO: Make collision check a static function.
							act_on_other(colliding_thing)

	result_array.append(result)

func act_on_other(other: Individual):
	var groups = other.get_groups()
	var is_in_a_throng = false # TOdO: any
	for group: String in groups:
		if group.begins_with('throng_'):
			is_in_a_throng = true
			break
	if not is_in_a_throng:
		print('Should add ', other, ' to throng')
		var root = self.get_node('/root/throng_root_node')
		var self_throng_id = self.get_throng_id()
		var throng: Throng = find_obj(
			root.get_children(),
			func(obj): return obj.name == 'Throng' and obj.throng_id == self_throng_id
		)
		print('root throng: ', throng)
		throng.add(other)

func recruit(recruitee: Node):
	pass

func get_throng_id():
	var groups = self.get_groups().filter(func (group: String): return group.begins_with('throng_'))
	if groups.size() > 0:
		assert(groups.size() == 1)
		return groups[0]

static func find_obj(array: Array, test: Callable):
	var filtered = array.filter(test)
	if filtered.size() > 0:
		return filtered[0]
