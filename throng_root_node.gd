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
var rng: RandomNumberGenerator

#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():	
	var seed_val = randi()
	#var seed_val = 4153177625 # Guy appears to get eaten before he moves into range.
	#var seed_val = 4051854102 # Trying to make an individual move that's already freed.
	#var seed_val = 2262306517 # Generates an alligator on top of a blob
	#var seed_val = 3637569141 # Immediate two individuals overlapping
	#var seed_val = 1794514250 # Up, right, right: Guy gets eaten by alligator after moving past it.
	print('seed: ', seed_val)
	self.rng = RandomNumberGenerator.new()
	self.rng.seed = seed_val

	var tilemap = $dungeon_tilemap
	tilemap.add_layer(0)
	var floor_points = MapGen.generate_map(
		rng.randi_range(map_gen_iteration_range[0], map_gen_iteration_range[0]),
		map_gen_branch_len_range,
		map_dimensions,
		self.rng
	)

	for point in floor_points:
		tilemap.set_cell(0, point, 0, tile_indexes_for_names.parquet)

	var possible_individual_locations = floor_points.duplicate()
	var player = individual_scene.instantiate()
	player.readable_name = 'player'
	player.rng = self.rng
	var player_location = Vector2(BasicUtils.pop_random(possible_individual_locations, self.rng))

	add_child(player)
	# The Individuals must be in the tree before change_position can be called
	# because get_node on absolute paths (which they need to get sprite_presenter)
	# won't work until the are.
	# position is the origin of the node. Since the node centers its children
	# around the origin, we have to put the position in the center of the tile.
	player.change_position((player_location + half_unit_vec) * tile_size)

	var throng = throng_scene.instantiate()
	throng.throng_id = 'throng_player'
	add_child(throng)
	throng.position = player.position

	for i in 5:
		var indiv_scene = individual_scene
		if rng.randi_range(0, 3) > 0:
			indiv_scene = alligator_scene		
		var individual = indiv_scene.instantiate()
		individual.rng = self.rng
		individual.readable_name = '%s_%d' % [individual.name, i]
		add_child(individual)
		var location = Vector2(BasicUtils.pop_random(possible_individual_locations, self.rng))
		individual.change_position((location + half_unit_vec) * tile_size)
	
	throng.add(player)
	self.sprite_presenter.sync_presentation()

func stall_op(done_signal, seconds):
	print('Stall start')
	await self.get_tree().create_timer(seconds).timeout
	print('Stall end')
	done_signal.emit()
