class_name SpritePresenter
extends Node2D

class Presentable:
	var arguments: Array
	var op: Callable
	
	func _init(the_op: Callable, the_arguments: Array):
		self.arguments = the_arguments
		self.op = the_op
 
var presentable_queue = []

func queue_presentable(presentable: Presentable):
	self.presentable_queue.append(presentable)

func sync_presentation():
	var presentable: Presentable = presentable_queue.pop_front()
	while presentable:
		await presentable.op.callv(presentable.arguments)
		presentable = presentable_queue.pop_front()
