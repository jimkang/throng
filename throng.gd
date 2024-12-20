class_name Throng
extends Node2D

@export var move_size: int
@export var throng_id: String
@export var initiative: int = 1
@export var readable_name: String = 'player_throng'

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('throngs')
	self.add_to_group('actors')

func take_turn(event: InputEvent):
	var x = 0
	var y = 0
	if event.is_action_released('ui_left'):
		x -= 1
	if event.is_action_released('ui_right'):
		x += 1
	if event.is_action_released('ui_up'):
		y -= 1
	if event.is_action_released('ui_down'):
		y += 1

	if x != 0 or y != 0 or event.is_action_released('act'):
		await push_throng(x, y)

func push_throng(x: int, y: int):
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
	for individual in individuals:
		# We need to wait for the move to take effect so that the next
		# collision calculations take it into account.
		# We need to wait even before moving the first individual in case there
		# was a physics change previous to this function call. We need that to
		# be taken into account.
		await get_tree().physics_frame
		if not individual:
			# May have been freed in the physics_frame.
			continue

		assert(individual.has_method('push_in_direction'))
		# print('Throng moving: ', individual.readable_name)
		var acting_but_not_moving = x == 0 and y == 0
		var push_direction = move
		if acting_but_not_moving:
			push_direction = individual.facing * move_size
		var push_result = await individual.push_in_direction(
			push_direction,
			true,
			true,
			!acting_but_not_moving) == Thing.ActionOutcome.moved
		if push_result:
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
	individual.remove_from_group('actors')
	if individual.sprite_root:
		individual.sprite_root.draw_facing_indicator = true
		individual.sprite_root.highlight_color = Color.YELLOW
		individual.sprite_root.queue_redraw()
	if individual.is_in_group('potential_recruiters'):
		individual.behavior = 'recruit'

func plant_throng(open_locations: Array[Vector2i], new_center: Vector2, level_contents_root: LevelContentsRoot):
	self.position = new_center
	var individuals = get_tree().get_nodes_in_group(self.throng_id)
	var placement = Geometry.find_contiguous_group_placements(self.position,
		open_locations, individuals.size())

	for i in placement.size():
		level_contents_root.move_to_place(individuals[i], placement[i])
