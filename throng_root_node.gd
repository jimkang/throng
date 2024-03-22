extends Node2D

@export var map_dimensions: Vector2i
@export var map_gen_iteration_range: Array
@export var map_gen_branch_len_range: Array = [2.0, 10.0]
@export var tile_size: int

@onready var sprite_presenter: SpritePresenter = $sprite_presenter
var individual_scene = preload('res://individual.tscn')
var alligator_scene = preload("res://alligator.tscn")
var throng_scene = preload('res://throng.tscn')

var tile_indexes_for_names = {
	'parquet': Vector2i(16, 0)
}
const half_unit_vec = Vector2(0.5, 0.5)

#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	add_user_signal('individual_move_done', [{'name': 'result', 'type': TYPE_BOOL }])

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
	var player = individual_scene.instantiate()
	var player_location = Vector2(possible_individual_locations.pick_random())

	print('Put player at ', player.position)
	possible_individual_locations.erase(player_location)
	add_child(player)
	# The Individuals must be in the tree before change_position can be called
	# because get_node on absolute paths (which they need to get sprite_presenter)
	# won't work until the are.
	# position is the origin of the node. Since the node centers its children
	# around the origin, we have to put the position in the center of the tile.
	player.change_position((player_location + half_unit_vec) * tile_size)
	#player.sync_presentation()

	var throng = throng_scene.instantiate()
	throng.throng_id = 'throng_player'
	add_child(throng)
	if throng is Throng:
		print('is class')
	else:
		print('is NOT class')
	throng.position = player.position

	for i in 5:
		var alligator = alligator_scene.instantiate()
		alligator.name = '%s_%d' % [alligator.get_class(), i]
		#alligator.unique_name_in_owner = true
		add_child(alligator)
		var alligator_location = Vector2(possible_individual_locations.pick_random())
		alligator.change_position((alligator_location + half_unit_vec) * tile_size)
		possible_individual_locations.erase(alligator_location)		
		#alligator.sync_presentation()
	
	throng.add(player)
	self.sprite_presenter.sync_presentation()
