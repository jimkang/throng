class_name Hierarchy
extends Node

static func find_obj(array: Array, test: Callable):
	var filtered = array.filter(test)
	if filtered.size() > 0:
		return filtered[0]
