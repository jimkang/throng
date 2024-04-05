class_name Presentable
extends Object

signal presentation_op_done(op_name)
var name: String
var arguments: Array
var op: Callable
var is_async: bool

func _init(the_name: String, the_op: Callable, the_arguments: Array, _is_async: bool):
	self.name = the_name
	self.arguments = the_arguments
	self.op = the_op
	self.is_async = _is_async

static func animation_op(done_signal, animation_player, animation_name):
	# Temporary until there's an animation for each facing sprite.
	var sprite = animation_player.get_parent().find_child('sprite_default', false, false)
	sprite.visible = true
	
	animation_player.play(animation_name)
	await animation_player.animation_finished
	done_signal.emit()
	
static func sprite_move_op(_done_signal, sprite_root: Node2D, new_position, facing: Vector2i):
	print('move_op with sprite: ', sprite_root.name)
	var facing_sprite_name = 'sprite_facing_%s' % get_direction_name(facing)
	print('facing_sprite:', facing_sprite_name)
	# sprite_root isn't going to be owned, so the fourth param here is important.
	var sprites = sprite_root.find_children('*', 'Sprite2D', false, false)
	var facing_sprite_is_visible = false
	for sprite in sprites:
		if sprite.name == facing_sprite_name:
			sprite.visible = true
			facing_sprite_is_visible = true
			sprite_root.sprite_facing = sprite
		else:
			sprite.visible = false
	if not facing_sprite_is_visible:
		var sprite = sprite_root.find_child('sprite_default', false, false)
		if sprite:
			sprite.visible = true
	
	sprite_root.position = new_position

static func free_op(_done_signal, node):
	node.queue_free()
	
static func get_direction_name(dir: Vector2i):
	match(dir):
		Vector2i.UP:
			return 'up'
		Vector2i.DOWN:
			return 'down'
		Vector2i.LEFT:
			return 'left'
		Vector2i.RIGHT:
			return 'right'
