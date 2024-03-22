class_name Throng
extends Node2D

@export var move_size: int 
@export var throng_id: String
@export var initiative: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('throngs')

func take_turn(event):
	var x = 0
	var y = 0
	if event.is_action_released("ui_left"):
		x -= 1
	if event.is_action_released("ui_right"):
		x += 1
	if event.is_action_released("ui_up"):
		y -= 1
	if event.is_action_released("ui_down"):
		y += 1

	if x != 0 or y != 0:
		move_throng(x, y)

func move_throng(x: int, y: int):
	var move = Vector2(x * move_size, y * move_size)
	var sort_fn = Hierarchy.compare_leftward
	if x > 0:
		sort_fn = Hierarchy.compare_rightward
	else:
		if x == 0:
			if y > 0:
				sort_fn = Hierarchy.compare_bottomwise
			else:
				sort_fn = Hierarchy.compare_topwise
				
	var individuals = get_tree().get_nodes_in_group(self.throng_id)
	individuals.sort_custom(sort_fn)
	
	var moved_individuals = []
	var last_individual_did_move = false
	for individual in individuals:
		if last_individual_did_move:
			# We need to wait for the move to take effect so that the next
			# collision calculations take it into account.
			await get_tree().physics_frame
		assert(individual is Individual)
		print('Moving: ', individual.name)
		last_individual_did_move = individual.move(move)
		if last_individual_did_move:
			moved_individuals.append(individual)
			
		# Can't use the existing individuals var here because some of them may have died.
		self.position = get_center_of_group(get_tree().get_nodes_in_group(self.throng_id))
	
func get_center_of_group(group: Array) -> Vector2:
	var positions = group.map(func (member): return member.position)
	#print('group positions: ', positions, ' center: ', Geometry.find_box_center(positions))
	return Vector2(Geometry.find_box_center(positions))

func add(individual: Node):
	if not individual.get_meta('individual'):
		return
	individual.add_to_group(self.throng_id)
	individual.remove_from_group('individuals')
