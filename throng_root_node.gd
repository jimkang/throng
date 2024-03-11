extends Node2D

@export var map_dimensions: Vector2i

var connect_test_cases = [
	[Vector2i(3, 6), Vector2i(8, 10)]
]

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
	
	var floor_points = []
	#floor_points.append_array(connect_points_linear(connect_test_cases[0][0], connect_test_cases[0][1], 4, []))
	var number_of_iterations = randi_range(1, 4)
	var current_node_pts = [Vector2i(
		randi_range(0, map_dimensions[0]-1),
		randi_range(0, map_dimensions[1]-1)
		)]
	
	for i in number_of_iterations:
		var iter_node_pts = []
		for node_pt in current_node_pts:
			var number_of_branches = randi_range(1, 3)
			for j in number_of_branches:
				var branch_connections: Array = create_branch(floor_points, node_pt)
				# Put the branch points into the array from which tiles will be
				# drawn.
				floor_points.append_array(branch_connections)
				# Can't append every single thing to the points that are to be
				# branched from; just the end points.
				if branch_connections.size() > 0:
					iter_node_pts.append(branch_connections.back())
		#print('iter ', i, ' results: ', iter_node_pts)
		current_node_pts = iter_node_pts
	
	#for i in joints.size():
		#for j in joints.size() - i:
			#if randi_range(0, 1) == 0:
				## Don't connect every single pair of joints.
				#continue
			#var connect_points_fn = connect_points_linear if randi_range(0, 2) > 0 else connect_points_stepwise; 
			#connect_points(floor_points, joints[i], joints[j], connect_points_fn)
	
	for point in floor_points:
		tilemap.set_cell(0, point, 0, tile_indexes_for_names.parquet) 
	#for x in map_dimensions[0]:
		#for y in map_dimensions[1]:
			#tilemap.set_cell(0, Vector2i(x, y), 0, tile_indexes_for_names.parquet) 

# ref_points are the points that should not be duplicated.
func create_branch(ref_points: Array, root_pt: Vector2i):
	var angle: float = randf_range(0.0, 2 * PI)
	var dist: float = randf_range(2, 10)
	var move_by = Vector2.from_angle(angle) * dist;	
	var dest_pt: Vector2i = Vector2i(Vector2(root_pt) + move_by).clamp(Vector2i.ZERO, map_dimensions);
	var connectors = connect_points(ref_points, root_pt, dest_pt, connect_points_linear)# connect_points_stepwise)
	var branch_pts = [root_pt] + connectors + [dest_pt]
	var diagonal_fills = get_diagonal_fills(ref_points, branch_pts)
	print(root_pt, ' to ', dest_pt, ' branch_pts: ', branch_pts, ' fills: ', diagonal_fills)
	return branch_pts + diagonal_fills
	
func connect_points(ref_array: Array, point_a: Vector2i, point_b: Vector2i, 
connect_points_fn: Callable = connect_points_linear):
	var steps = get_steps_needed_between_pts(point_a, point_b)
	#print('steps ', steps, ', point_a ',  point_a, ', point_b ', point_b)
	var float_pt_a = Vector2(point_a)
	var float_pt_b = Vector2(point_b)
	
	var connectors = connect_points_fn.call(float_pt_a, float_pt_b, steps, ref_array)		
	#print('a ', point_a, ' to b ', point_b, ' connectors ', connectors)
	return connectors

static func connect_points_linear(float_pt_a: Vector2, float_pt_b: Vector2, steps: int, ref_array: Array):
	var connectors = []
	var step_size = 1.0/steps
	for i in steps:
		var step_pt = Vector2i(float_pt_a.lerp(float_pt_b, i * step_size))
		non_dupe_append(connectors, ref_array, step_pt)
	return connectors

static func connect_points_stepwise(float_pt_a: Vector2, float_pt_b: Vector2, _steps: int, ref_array: Array):
	var connectors = []
	var a_to_b: Vector2 = float_pt_b - float_pt_a
	
	var y_min = float_pt_a.y
	var y_max = y_min + a_to_b.y
	if a_to_b.y < 0:
		y_min = y_max
		y_max = float_pt_a.y
		
	for y in range(y_min, y_max + 1):
		non_dupe_append(connectors, ref_array, Vector2i(float_pt_a.x, y))
	
	var x_min = float_pt_a.x
	var x_max = x_min + a_to_b.x
	if a_to_b.x < 0:
		x_min = x_max
		x_max = float_pt_a.x
		
	for x in range(x_min, x_max + 1):
		non_dupe_append(connectors, ref_array, Vector2i(x, float_pt_b.y))
	print(float_pt_a, ' to ', float_pt_b, ' stepwise connectors: ', connectors)
	return connectors

static func get_diagonal_fills(existing_pts, line_pts):
	var diagonal_fills = []
	for i in range(1, line_pts.size()):
		var prev_pt: Vector2i = line_pts[i - 1] 
		var pt = line_pts[i]
		var delta_x = pt.x - prev_pt.x
		if delta_x != 0:
			var slope = (pt.y - prev_pt.y)/delta_x
			if slope != 0:
				var steps = get_steps_needed_between_pts(prev_pt, pt)
				diagonal_fills.append_array(connect_points_stepwise(prev_pt, pt, steps, existing_pts))
	return diagonal_fills
				## TODO: What if the slope is far from 1?
				#var delta_y = step_pt.y - prev_pt.y
				#non_dupe_append(connectors, ref_array,
				#Vector2i(prev_pt.x + delta_x, prev_pt.y))
				#non_dupe_append(connectors, ref_array,
				#Vector2i(ceil(prev_pt.x + delta_x), ceil(prev_pt.y)))
				#non_dupe_append(connectors, ref_array,
				#Vector2i(prev_pt.x, prev_pt.y + delta_y))
				#non_dupe_append(connectors, ref_array,
				#Vector2i(ceil(prev_pt.x), ceil(prev_pt.y + delta_y)))

static func get_steps_needed_between_pts(point_a, point_b):
	var width = max(abs(point_a.x - point_b.x), 1)
	var height = max(abs(point_a.y - point_b.y), 1)
	var steps = 1;
	if (width > height):
		steps = width
	else:
		steps = height
	return steps
	
static func non_dupe_append(array, ref_array, thing):
	if not thing in ref_array and not thing in array:
		array.append(thing)
		return true
	return false
