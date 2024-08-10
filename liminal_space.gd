class_name LiminalSpace
extends Node2D

@onready var scene_tree = self.get_tree()

func _on_child_order_changed():
	var children: Array[Node] = self.get_children()
	#print('liminal_space children', children)
	var throng_members: Array[Node] = scene_tree.get_nodes_in_group('throng_player')
	if throng_members.all(func (member): return children.has(member)):
		print('Entire throng is in liminal space.')
		self.emit_signal('level_complete')
	else:
		print('Some of throng is missing from liminal space.')
	
