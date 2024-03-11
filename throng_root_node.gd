extends Node2D

@export var map_dimensions: Vector2i
@export var map_gen_iteration_range: Array
@export var map_gen_branch_len_range: Array = [2.0, 10.0]
@export var tile_size: int
@export var Individual: PackedScene

var Alligator = preload("res://alligator.tscn")

var tile_indexes_for_names = {
	'parquet': Vector2i(16, 0)
}
#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	var tilemap = $dungeon_tilemap
	tilemap.add_layer(0)
	var floor_points = $map_gen.generate_map(
		randi_range(map_gen_iteration_range[0], map_gen_iteration_range[0]),
		map_gen_branch_len_range, map_dimensions
	)

	for point in floor_points:
		tilemap.set_cell(0, point, 0, tile_indexes_for_names.parquet) 
	
	var player = Individual.instantiate()
	player.position = floor_points.pick_random() * tile_size
	add_child(player)
	
	var alligator = Alligator.instantiate()
	alligator.position = floor_points.pick_random() * tile_size
	add_child(alligator)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
