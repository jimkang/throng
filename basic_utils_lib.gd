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

class UniqueArray extends Object:
	var hash = {}
	var array = []
	func append(item: Variant):
		if item in hash:
			return
		array.append(item)
		hash[item] = true
	func prepend(item: Variant):
		if item in hash:
			return
		array.push_front(item)
		hash[item] = true
	func size():
		return array.size()
	func back():
		return array.back()
	func append_array(other_array: Array):
		other_array.map(self.append)
		return self
	# If you need to optimize, it's better to append the shorter unique array
	# to the longer one, rather than the other way around.
	func append_unique_array(other_unique_array: UniqueArray):
		return self.append_array(other_unique_array.to_array())
	func to_array():
		return array
	func copy():
		var copy_array = UniqueArray.new()
		copy_array.hash = self.hash.duplicate(true)
		copy_array.array = self.array.duplicate(true)
		return copy_array
	
