class_name Hierarchy
extends Node

static func find_obj(array: Array, test: Callable):
	var filtered = array.filter(test)
	if filtered.size() > 0:
		return filtered[0]

# Returns false if a should come before b.
static func compare_leftward(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.x < b.position.x
	# If a is left of b, return false to make it get sorted first.
	
static func compare_rightward(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.x > b.position.x
	
static func compare_topwise(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.y < b.position.y
	
static func compare_bottomwise(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	print(a.position, ' and ', b.position, ' result', a.position.y > b.position.y)
	return a.position.y > b.position.y
