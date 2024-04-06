class_name Geometry
extends Object

static func find_box_center(points: Array) -> Vector2i:
	var box = find_box(points)
	return box.get_center()

static func find_box(points: Array) -> Rect2i:
	var leftmost = null
	var rightmost = null
	var topmost = null
	var bottommost = null
	for point: Vector2i in points:
		if leftmost == null || point.x < leftmost:
			leftmost = point.x
		if rightmost == null || point.x > rightmost:
			rightmost = point.x
		if topmost == null || point.y < topmost:
			topmost = point.y
		if bottommost == null || point.y > bottommost:
			bottommost = point.y
	return Rect2i(leftmost, topmost, rightmost - leftmost, bottommost - topmost)

static func name_for_direction(dir: Vector2i):
	match dir:
		Vector2i.LEFT:
			return 'left'
		Vector2i.RIGHT:
			return 'right'
		Vector2i.UP:
			return 'up'
		Vector2i.DOWN:
			return 'down'
	
