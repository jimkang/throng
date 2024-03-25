class_name BasicUtils
extends Node

static func pop_random(array: Array, rng: RandomNumberGenerator):
	var index = rng.randi_range(0, array.size() - 1)
	return array.pop_at(index)
		
static func pick_random(array: Array, rng: RandomNumberGenerator):
	var index = rng.randi_range(0, array.size() - 1)
	if index > -1 and index < array.size():
		return array[index]

static func non_dupe_append(array, ref_array, thing):
	if not thing in ref_array and not thing in array:
		array.append(thing)
		return true
	return false

