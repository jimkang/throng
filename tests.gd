class_name Tests
extends Object

@export var tests_on: bool

func _ready():
	if tests_on:
		test_map_gen()

func test_map_gen():
	var seed_val = randi()
	print('test seed: ', seed_val)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_val
	var floor_points = MapGen.generate_map(6, [2, 10], Vector2i(24, 24), rng)
	for i in floor_points.size():
		var point = floor_points[i]
		var rest_of_points = floor_points.slice(i + 1)
		var dupe_index = rest_of_points.find(point)
		assert(dupe_index == -1, 'Point %s duplicated at %d.' % [point, dupe_index + i + 1])
