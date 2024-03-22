extends Node

class_name Map_Gen

static func generate_map(number_of_iterations: int, 
	map_gen_branch_len_range: Array, map_dimensions: Vector2i):
	var floor_points = []

	var current_node_pts = [Vector2i(
		randi_range(0, map_dimensions[0]-1),
		randi_range(0, map_dimensions[1]-1)
		)]
	
	for i in number_of_iterations:
		var iter_node_pts = []
		for node_pt in current_node_pts:
			var number_of_branches = randi_range(1, 3)
			for j in number_of_branches:
				var branch_connections: Array = create_branch(floor_points, 
				node_pt, map_gen_branch_len_range, map_dimensions)
				# Put the branch points into the array from which tiles will be
				# drawn.
				floor_points.append_array(branch_connections)
				# Can't append every single thing to the points that are to be
				# branched from; just the end points.
				if branch_connections.size() > 0:
					iter_node_pts.append(branch_connections.back())
		current_node_pts = iter_node_pts
		
	return floor_points

# ref_points are the points that should not be duplicated.
static func create_branch(ref_points: Array, root_pt: Vector2i, map_gen_branch_len_range: Array, map_dimensions: Vector2i):
	var angle: float = randf_range(0.0, 2 * PI)
	var dist: float = randf_range(map_gen_branch_len_range[0], map_gen_branch_len_range[1])
	var move_by = Vector2.from_angle(angle) * dist;	
	var dest_pt: Vector2i = Vector2i(Vector2(root_pt) + move_by).clamp(Vector2i.ZERO, map_dimensions);
	var connectors = connect_points(ref_points, root_pt, dest_pt, Map_Gen.connect_points_linear)# connect_points_stepwise)
	var branch_pts = [root_pt] + connectors + [dest_pt]
	var diagonal_fills = get_diagonal_fills(ref_points, branch_pts)
	#print(root_pt, ' to ', dest_pt, ' branch_pts: ', branch_pts, ' fills: ', diagonal_fills)
	return branch_pts + diagonal_fills


static func connect_points_stepwise(float_pt_a: Vector2, float_pt_b: Vector2, _steps: int, ref_array: Array):
	var connectors = []
	var a_to_b: Vector2 = float_pt_b - float_pt_a
	
	var y_min = float_pt_a.y
	var y_max = y_min + a_to_b.y
	if a_to_b.y < 0:
		y_min = y_max
		y_max = float_pt_a.y
		
	for y in range(y_min, y_max + 1):
		non_dupe_append(connectors, ref_array, Vector2i(int(float_pt_a.x), y))
	
	var x_min = float_pt_a.x
	var x_max = x_min + a_to_b.x
	if a_to_b.x < 0:
		x_min = x_max
		x_max = float_pt_a.x
		
	for x in range(x_min, x_max + 1):
		non_dupe_append(connectors, ref_array, Vector2i(x, int(float_pt_b.y)))
	#print(float_pt_a, ' to ', float_pt_b, ' stepwise connectors: ', connectors)
	return connectors

static func connect_points_linear(float_pt_a: Vector2, float_pt_b: Vector2, steps: int, ref_array: Array):
	var connectors = []
	var step_size = 1.0/steps
	for i in steps:
		var step_pt = Vector2i(float_pt_a.lerp(float_pt_b, i * step_size))
		non_dupe_append(connectors, ref_array, step_pt)
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
	
static func connect_points(ref_array: Array, point_a: Vector2i, point_b: Vector2i, 
connect_points_fn: Callable = connect_points_linear):
	var steps = get_steps_needed_between_pts(point_a, point_b)
	var float_pt_a = Vector2(point_a)
	var float_pt_b = Vector2(point_b)
	
	var connectors = connect_points_fn.call(float_pt_a, float_pt_b, steps, ref_array)		
	return connectors
	
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
