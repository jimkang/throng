class_name Individual
extends Node2D

@export var color_set: PackedColorArray
var tilemap: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = color_set[randi_range(0, color_set.size()-1)]
	tilemap = self.get_node('/root/throng_root_node/dungeon_tilemap')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func sync_presentation():
	print('setting sprite at ', $Sprite2D.position, ' to ', $Area2D.position)
	$Sprite2D.position = $Area2D.position
	
# Returns true if we were actually able to move.
func move(move_vector: Vector2):
	var next_pos = $Area2D.position + move_vector
	var dest_cell_data := cell_data_at_pos(next_pos)
	var result = false
	if dest_cell_data:
		# If the dest on a floor, then we can do something, maybe.
		if dest_cell_data.get_custom_data('is_floor'):
			var colliding_thing = Collision.find_colliding_things_at(
				get_world_2d().direct_space_state, next_pos)
			if colliding_thing:
				if colliding_thing.get_meta('individual'):
					act_on_other(colliding_thing)
			else:
				# If nothing's on the floor there, we can go there. 
				$Area2D.position += move_vector
				result = true
	return result

func cell_data_at_pos(pos: Vector2) -> TileData:
	var next_cell_pos = tilemap.local_to_map(tilemap.to_local(pos))
	return tilemap.get_cell_tile_data(0, next_cell_pos)

func act_on_other(other: Individual):
	# TODO: Individual's primary action, if any.
	recruit(other)

func recruit(recruitee: Individual):
	var groups = recruitee.get_groups()
	var is_in_a_throng = groups.any(func (group): return group.begins_with('throng_'))
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
