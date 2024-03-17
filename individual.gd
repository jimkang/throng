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
	var dest_cell_data = tilemap.get_cell_tile_data(0, next_cell_pos)
	var result = false
	if dest_cell_data:
		var is_floor = dest_cell_data.get_custom_data('is_floor')		
		if is_floor:
			var colliding_thing = Collision.find_colliding_things_at(
				get_world_2d().direct_space_state, next_pos)
			if colliding_thing:
				if colliding_thing.get_meta('individual'):
					# TODO: Make collision check a static function.
					act_on_other(colliding_thing)
			else:
				self.position += move_vector
				result = true

	result_array.append(result)

func act_on_other(other: Individual):
	# TODO: Individual's primary action, if any.
	recruit(other)

func recruit(recruitee: Individual):
	var groups = recruitee.get_groups()
	var is_in_a_throng = false # TOdO: any
	for group: String in groups:
		if group.begins_with('throng_'):
			is_in_a_throng = true
			break
	if not is_in_a_throng:
		var root = self.get_node('/root/throng_root_node')
		var self_throng_id = self.get_throng_id()
		var throng: Throng = Hierarchy.find_obj(
			root.get_children(),
			func(obj): return obj.name == 'Throng' and obj.throng_id == self_throng_id
		)
		throng.add(recruitee)

func get_throng_id():
	var groups = self.get_groups().filter(func (group: String): return group.begins_with('throng_'))
	if groups.size() > 0:
		assert(groups.size() == 1)
		return groups[0]
