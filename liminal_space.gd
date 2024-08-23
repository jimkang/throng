class_name LiminalSpace
extends Node2D

signal level_complete
@onready var scene_tree = self.get_tree()
var level_completed = false

func _on_child_order_changed():
	check_for_level_completion()

func check_for_level_completion():
	if self.level_completed:
		return

	var children: Array[Node] = self.get_children()
	#print('liminal_space children', children)
	var throng_members: Array[Node] = scene_tree.get_nodes_in_group('throng_player')
	if throng_members.all(func (member): return children.has(member)):
		print('Entire throng is in liminal space.')
		self.level_completed = true

		# Emit this deferred so that it happens *after* the physics update
		# and so respondents don't have to worry about being inside of that.
		self.call_deferred('emit_level_complete')
	else:
		print('Some of throng is missing from liminal space.')

func emit_level_complete():
	level_complete.emit()

func reset_level():
	self.level_completed = false
	Hierarchy.remove_all_children(self)
