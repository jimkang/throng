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
	#pass
	animation_player.play(animation_name)
	#animation_player.advance(0)
	await animation_player.animation_finished
	done_signal.emit()
	
static func sprite_move_op(_done_signal, node, new_position):
	node.position = new_position

static func free_op(_done_signal, node):
	node.queue_free()
	
