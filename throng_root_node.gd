class_name RootNode
extends Node2D

@export var map_dimensions: Vector2i
@export var map_gen_iteration_range: Array
@export var map_gen_branch_len_range: Array = [2.0, 10.0]
@export var tile_size: int

var individual_scene = preload('res://individual.tscn')

@onready var sprite_presenter: SpritePresenter = $sprite_presenter
@onready var tilemap: TileMapLayer = $dungeon_tilemap
@onready var level_contents_root: LevelContentsRoot = $level_contents_root

var tile_indexes_for_names = {
	'parquet': Vector2i(16, 0)
}
var rng: RandomNumberGenerator

#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	Behaviors.register_act('recruit', ThrongBehaviors.recruit)

	var seed_val = randi()
	#var seed_val = 227686610 # Alligator in throng doing extra moves.
	#var seed_val = 4153177625 # Guy appears to get eaten before he moves into range.
	#var seed_val = 4051854102 # Trying to make an thing move that's already freed.
	#var seed_val = 2262306517 # Generates an alligator on top of a blob
	#var seed_val = 3637569141 # Immediate two things overlapping
	#var seed_val = 1794514250 # Up, right, right: Guy gets eaten by alligator after moving past it.
	print('seed: ', seed_val)
	self.rng = RandomNumberGenerator.new()
	self.rng.seed = seed_val

	# Maybe level_contents_root should be constructed?
	# Also, these can get out of sync.
	self.level_contents_root.rng = self.rng
	self.level_contents_root.tile_size = self.tile_size

	var possible_individual_locations = self.set_up_new_level()
	var player = self.set_up_player(possible_individual_locations)

	var throng = $throng
	throng.position = player.position
	throng.add(player)	

	self.sprite_presenter.sync_presentation()

func clear_current_level():
	self.tilemap.clear()
	self.level_contents_root.depopulate_level()

func stall_op(done_signal, seconds):
	await self.get_tree().create_timer(seconds).timeout
	done_signal.emit()

func set_up_new_level() -> Array[Vector2i]:
	var floor_points = MapGen.generate_map(
		rng.randi_range(map_gen_iteration_range[0], map_gen_iteration_range[0]),
		map_gen_branch_len_range,
		map_dimensions,
		self.rng
	)

	for point in floor_points:
		self.tilemap.set_cell(point, 0, tile_indexes_for_names.parquet)

	var possible_individual_locations = floor_points.duplicate()
	self.level_contents_root.populate_level(possible_individual_locations)

	self.sprite_presenter.sync_presentation()
	return possible_individual_locations as Array[Vector2i]

func set_up_player(possible_individual_locations: Array):
	var player = individual_scene.instantiate()
	player.readable_name = 'player'
	player.rng = self.rng
	var player_location = Vector2(BasicUtils.pop_random(possible_individual_locations, self.rng))
	self.level_contents_root.add_child(player)
	# The Individuals must be in the tree before change_position can be called
	# because get_node on absolute paths (which they need to get sprite_presenter)
	# won't work until the are.
	# position is the origin of the node. Since the node centers its children
	# around the origin, we have to put the position in the center of the tile.
	player.face_direction(Vector2i.DOWN)
	player.change_position((player_location + Geometry.half_unit_vec) * tile_size)
	return player
