class_name Tests
extends Node

@export var tests_on: bool

func _ready():
	test_map_gen()

func test_map_gen():
	var seed_val = randi()
	print('test seed: ', seed_val)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val
	var floor_points = $'../map_gen'.generate_map(6, [2, 10], Vector2i(24, 24), rng)
	for i in floor_points.size():
		var point = floor_points[i]
		var dupe_index = floor_points.slice(i + 1).find(point) + i + 1
		assert(dupe_index == -1, 'Point %s duplicated at %d.' % [point, dupe_index])
