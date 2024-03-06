extends Node2D

@export var map_dimensions: Vector2i

var tile_indexes_for_names = {
	'parquet': Vector2i(16, 0)
}
#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generate_map():
	var tilemap = $dungeon_tilemap
	tilemap.add_layer(0)
	
	var joints = []
	# Add junctions
	for i in randi_range(8, 12):
		var point = Vector2i(randi_range(0, map_dimensions[0]),
			randi_range(0, map_dimensions[1]))
		if not point in joints:
			joints.append(point)
	
	print('joints: ', joints)
	var floor_points = joints.duplicate()
	
	for i in joints.size():
		for j in joints.size() - i:
			connect_points(floor_points, joints[i], joints[j])
	
	for point in floor_points:
		tilemap.set_cell(0, point, 0, tile_indexes_for_names.parquet) 
	#for x in map_dimensions[0]:
		#for y in map_dimensions[1]:
			#tilemap.set_cell(0, Vector2i(x, y), 0, tile_indexes_for_names.parquet) 

func connect_points(dest_array: Array, point_a: Vector2i, point_b: Vector2i):
	var width = abs(point_a.x - point_b.x);
	var height = abs(point_b.y - point_b.y);
	var steps = 1;
	if (width > height):
		steps = width
	else:
		steps = height
	
	var float_pt_a = Vector2(point_a)
	var float_pt_b = Vector2(point_b)
	
	var connectors = []
	var step_size = 1.0/steps
	for i in steps:
		var step_pt = Vector2i(float_pt_a.lerp(float_pt_b, i * step_size))
		if not step_pt in dest_array:
			connectors.append(step_pt)
			if connectors.size() > 1:
				var prev_pt: Vector2i = connectors[connectors.size() - 2] 
				var delta_x = step_pt.x - prev_pt.x
				if delta_x != 0:
					var slope = (step_pt.y - prev_pt.y)/delta_x
					if slope != 1:
						# Fill in the diagonals. TODO: What if the slope is far from 1?
						var delta_y = step_pt.y - prev_pt.y
						non_dupe_append(connectors, Vector2i(prev_pt.x + delta_x, prev_pt.y))
						non_dupe_append(connectors, Vector2i(prev_pt.x, prev_pt.y + delta_y))
	
	print('a ', point_a, ' to b ', point_b, ' connectors ', connectors)
	dest_array.append_array(connectors)
	return dest_array

func non_dupe_append(array, thing):
	if not thing in array:
		array.append(thing)
		return true
	return false
