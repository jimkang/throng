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

#static func bump_animation_op():

static func sprite_animation_op(done_signal, sprite_root: IndividualSpriteRoot,
animated_sprite: AnimatedSprite2D):
	animated_sprite.visible = true
	# Hide non-animated sprites.
	var active_sprite = sprite_root.sprite_facing if sprite_root.sprite_facing else sprite_root.sprite_default
	var animation_root = animated_sprite.get_parent()
	active_sprite.visible = false
	animated_sprite.visible = true
	animation_root.visible = true
	animated_sprite.play()
	
	await animated_sprite.animation_finished
	
	animated_sprite.visible = false
	animation_root.visible = false
	active_sprite.visible = true
	done_signal.emit()

static func sprite_face_op(_done_signal, sprite_root: Node2D, facing: Vector2i):
	print('face_op with sprite: ', sprite_root.name)
	var facing_sprite_name = 'sprite_facing_%s' % Geometry.name_for_direction(facing)
	print('facing_sprite:', facing_sprite_name)
	var facing_sprite_is_visible = false
	var facing_sprite = Hierarchy.make_only_visible_sibling(sprite_root,
	facing_sprite_name)
	
	if facing_sprite:
		facing_sprite_is_visible = true
		sprite_root.sprite_facing = facing_sprite		
	if not facing_sprite_is_visible:
		var sprite = sprite_root.find_child('sprite_default', false, false)
		if sprite:
			sprite.visible = true

static func sprite_move_op(_done_signal, sprite_root: Node2D, new_position: Vector2i):
	sprite_root.position = new_position

static func free_op(_done_signal, node):
	node.queue_free()

