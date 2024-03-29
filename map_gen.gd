class_name MapGen
extends Object

static func generate_map(number_of_iterations: int, 
	map_gen_branch_len_range: Array, map_dimensions: Vector2i,
	rng: RandomNumberGenerator):
	var floor_points = BasicUtils.UniqueArray.new()

	var current_node_pts = [Vector2i(
		rng.randi_range(0, map_dimensions[0]-1),
		rng.randi_range(0, map_dimensions[1]-1)
		)]
	
	for i in number_of_iterations:
		var iter_node_pts = []
		for node_pt in current_node_pts:
			var number_of_branches = rng.randi_range(1, 3)
			for j in number_of_branches:
				var branch_connections: BasicUtils.UniqueArray = create_branch(node_pt, 
				map_gen_branch_len_range, map_dimensions, rng)
				# Put the branch points into the array from which tiles will be
				# drawn.
				floor_points.append_unique_array(branch_connections)
				# Can't append every single thing to the points that are to be
				# branched from; just the end points.
				if branch_connections.size() > 0:
					iter_node_pts.append(branch_connections.back())
		current_node_pts = iter_node_pts
	# NEXT: Still producing duplicate points
	print('floor_points: ', floor_points.to_array())
	return floor_points.to_array()

# ref_points are the points that should not be duplicated.
static func create_branch(root_pt: Vector2i, map_gen_branch_len_range: Array,
map_dimensions: Vector2i, rng: RandomNumberGenerator) -> BasicUtils.UniqueArray:
	var angle: float = rng.randf_range(0.0, 2 * PI)
	var dist: float = rng.randf_range(map_gen_branch_len_range[0], map_gen_branch_len_range[1])
	var move_by = Vector2.from_angle(angle) * dist;	
	var dest_pt: Vector2i = Vector2i(Vector2(root_pt) + move_by).clamp(Vector2i.ZERO, map_dimensions);
	var connectors: BasicUtils.UniqueArray = connect_points(root_pt, dest_pt, MapGen.connect_points_linear)# connect_points_stepwise)
	var branch_pts = connectors.copy()
	branch_pts.prepend(root_pt)
	branch_pts.append(dest_pt)
	var diagonal_fills: BasicUtils.UniqueArray = get_diagonal_fills(branch_pts.to_array())
	branch_pts.append_unique_array(diagonal_fills)
	return branch_pts

static func connect_points_stepwise(float_pt_a: Vector2, float_pt_b: Vector2) -> BasicUtils.UniqueArray:
	var connectors = BasicUtils.UniqueArray.new()
	var a_to_b: Vector2 = float_pt_b - float_pt_a
	
	var y_min = float_pt_a.y
	var y_max = y_min + a_to_b.y
	if a_to_b.y < 0:
		y_min = y_max
		y_max = float_pt_a.y
		
	for y in range(y_min, y_max + 1):
		connectors.append(Vector2i(int(float_pt_a.x), y))
	
	var x_min = float_pt_a.x
	var x_max = x_min + a_to_b.x
	if a_to_b.x < 0:
		x_min = x_max
		x_max = float_pt_a.x
		
	for x in range(x_min, x_max + 1):
		connectors.append(Vector2i(x, int(float_pt_b.y)))
	#print(float_pt_a, ' to ', float_pt_b, ' stepwise connectors: ', connectors)
	return connectors

static func connect_points_linear(float_pt_a: Vector2, float_pt_b: Vector2,
steps: int) -> BasicUtils.UniqueArray:
	var connectors = BasicUtils.UniqueArray.new()
	var step_size = 1.0/steps
	for i in steps:
		var step_pt = Vector2i(float_pt_a.lerp(float_pt_b, i * step_size))
		connectors.append(step_pt)
	return connectors

static func get_diagonal_fills(line_pts: Array) -> BasicUtils.UniqueArray:
	var diagonal_fills = BasicUtils.UniqueArray.new()
	for i in range(1, line_pts.size()):
		var prev_pt: Vector2i = line_pts[i - 1] 
		var pt = line_pts[i]
		var delta_x = pt.x - prev_pt.x
		if delta_x != 0:
			var slope = (pt.y - prev_pt.y)/delta_x
			if slope != 0:
				diagonal_fills.append_unique_array(connect_points_stepwise(prev_pt, pt))
	return diagonal_fills
	
static func connect_points(point_a: Vector2i, point_b: Vector2i, 
connect_points_fn: Callable = connect_points_linear) -> BasicUtils.UniqueArray:
	var steps = get_steps_needed_between_pts(point_a, point_b)
	var float_pt_a = Vector2(point_a)
	var float_pt_b = Vector2(point_b)
	
	return connect_points_fn.call(float_pt_a, float_pt_b, steps)
	
static func get_steps_needed_between_pts(point_a, point_b):
	var width = max(abs(point_a.x - point_b.x), 1)
	var height = max(abs(point_a.y - point_b.y), 1)
	var steps = 1;
	if (width > height):
		steps = width
	else:
		steps = height
	return steps
	
