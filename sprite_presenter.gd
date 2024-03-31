class_name SpritePresenter
extends Node2D
 
var presentable_queue = []

func queue_presentable(presentable: Presentable):
	self.presentable_queue.append(presentable)

func sync_presentation():
	var presentable: Presentable = presentable_queue.pop_front()
	# We need to use a while loop because a for wouldn't account for things
	# being destroyed while iterating.
	while presentable:
	#for presentable in presentable_queue:
		print('running presentable: ', presentable.name)
		var args = [presentable.presentation_op_done] + presentable.arguments
		print('presentable op: ', presentable.op)
		presentable.op.callv(args)
		if presentable.is_async:
			await presentable.presentation_op_done
		#print('Done awaiting: ', finished_op)
		presentable = presentable_queue.pop_front()
	#self.presentable_queue.clear()
