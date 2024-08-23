class_name LevelUsher
extends Node

@onready var game_root = $/root/game_root
@onready var level_contents_root = $/root/game_root/level_contents_root
@onready var liminal_space = $/root/game_root/liminal_space
@onready var tilemap: TileMap = $/root/game_root/dungeon_tilemap
@onready var throng: Throng = $/root/game_root/throng
@onready var scene_tree = self.get_tree()

func _ready():
	self.liminal_space.level_complete.connect(self.usher_in_new_level)

func usher_in_new_level():
	print('Starting new level.')
	self.game_root.clear_current_level()
	var open_locations: Array = self.game_root.set_up_new_level()
	self.move_guys_to_new_level(open_locations)
	var root_children = self.level_contents_root.get_children()
	var guys: Array[Node] = root_children.filter(Hierarchy.is_in_player_throng)
	assert(guys.size() > 0)
	self.throng.position = guys[0].position
	print('Adopting %s\'s position %v. New throng.position: %v' %
		[guys[0], guys[0].position, self.throng.position])
	self.game_root.sprite_presenter.sync_presentation()
	$/root/game_root/liminal_space.reset_level()

func move_guys_to_new_level(open_locations: Array):
	var throng_things = self.liminal_space.get_children().filter(
		Hierarchy.is_in_player_throng)

	for guy in throng_things:
		guy.exit_liminal_space(self.level_contents_root)
		# TODO: Make sure the throng stays together.
		var location = Vector2(BasicUtils.pop_random(open_locations, self.game_root.rng))
		# Can't do this while "flushing queries". Probably from remove_child.
		self.level_contents_root.move_to_place(guy, location)
