extends Node2D

@export var map_dimensions: Vector2i
@export var map_gen_iteration_range: Array
@export var map_gen_branch_len_range: Array = [2.0, 10.0]
@export var tile_size: int
@export var Individual: PackedScene

var Alligator = preload("res://alligator.tscn")
var Throng = preload('res://throng.tscn')

var tile_indexes_for_names = {
	'parquet': Vector2i(16, 0)
}
const half_unit_vec = Vector2(0.5, 0.5)

#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap = $dungeon_tilemap
	tilemap.add_layer(0)
	var floor_points = $map_gen.generate_map(
		randi_range(map_gen_iteration_range[0], map_gen_iteration_range[0]),
		map_gen_branch_len_range,
		map_dimensions
	)

	for point in floor_points:
		tilemap.set_cell(0, point, 0, tile_indexes_for_names.parquet)

	var possible_individual_locations = floor_points.duplicate()
	var player = Individual.instantiate()
	var player_location = Vector2(possible_individual_locations.pick_random())
	# position is the origin of the node. Since the node centers its children
	# around the origin, we have to put the position in the center of the tile.
	player.position = (player_location + half_unit_vec) * tile_size
	print('Put player at ', player.position)
	possible_individual_locations.erase(player_location)
	add_child(player)

	var throng = Throng.instantiate()
	add_child(throng)
	throng.position = player.position

	var alligator = Alligator.instantiate()
	var alligator_location = Vector2(possible_individual_locations.pick_random())
	alligator.position = (alligator_location + half_unit_vec) * tile_size
	possible_individual_locations.erase(alligator_location)
	add_child(alligator)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
