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
		print('is_floor: ', is_floor)
		if is_floor:
			self.position += move_vector
			result = true
	result_array.append(result)
