class_name Individual
extends Node2D

@export var readable_name: String
@export var color_set: PackedColorArray
@export var initiative: int = 10
# WARNING: This needs to be set after instantiation and before adding to the scene.
var rng: RandomNumberGenerator

@onready var tilemap: TileMap = $/root/throng_root_node/dungeon_tilemap
@onready var sprite_root: Node2D = $sprite_root
@onready var sprite_presenter: SpritePresenter = $/root/throng_root_node/sprite_presenter
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# Keep the reference to the sprite but remove it as a child so that when
	# this node's position changes, the sprite's does not. This makes it possible
	# to batch sprite updates in a single frame and avoid flicker.
	remove_child($sprite_root)
	self.sprite_presenter.add_child(self.sprite_root)
	self.add_to_group('individuals')
	
	self.sprite_root.get_child(0).modulate = color_set[rng.randi_range(0, color_set.size()-1)]

func animation_op(animation_player, animation_name):
	animation_player.play(animation_name)
	await animation_player.animation_finished

func sprite_move_op(node, new_position):
	node.position = new_position

func take_turn(_event):
	pass
	
# Returns true if we were actually able to move.
func move(move_vector: Vector2):
	var next_pos = self.position + move_vector
	var dest_cell_data := cell_data_at_pos(next_pos)
	var result = false
	if dest_cell_data:
		# If the dest on a floor, then we can do something, maybe.
		if dest_cell_data.get_custom_data('is_floor'):
			var colliding_thing = Collision.find_colliding_things_at(
				get_world_2d().direct_space_state, next_pos)
			print('Mover ', self.readable_name, ' is collding with: ',
			colliding_thing.readable_name if colliding_thing else 'nothing')

			if colliding_thing:
				if colliding_thing.get_meta('individual'):
					act_on_other(colliding_thing)
			else:
				# If nothing's on the floor there, we can go there. 
				self.change_position(self.position + move_vector)
				result = true
	return result

func change_position(pos: Vector2):
	self.position = pos
	self.sprite_presenter.queue_presentable(SpritePresenter.Presentable.new(
			self.sprite_move_op, [self.sprite_root, self.position]
	))

func die():
	self.sprite_presenter.queue_presentable(SpritePresenter.Presentable.new(
		self.sprite_root.queue_free, []
	))
	self.queue_free()

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
