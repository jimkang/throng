class_name Throng
extends Node2D

@export var move_size: int 
@export var throng_id: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	handle_move(event)

func handle_move(event):
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
	var result_array = []
	# Next: See if there's a way to call the group in order to avoid
	# unnecessary bumps among throng members.
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
	print('pre-sort: ', individuals)
	individuals.sort_custom(sort_fn)
	print('post-sort: ', individuals)
	
	var last_individual_did_move = false
	for individual in individuals:
		if last_individual_did_move:
			await get_tree().physics_frame
		assert(individual is Individual)
		print('Moving: ', individual.name)
		last_individual_did_move = individual.move(move, result_array)
		#print('individual call back from await')

	#get_tree().call_group(self.throng_id, 'move', move, result_array)
	# We need to update the camera in the same frame that we move the sprites
	# in to avoid flicker. That's why we don't await physics_frame between a
	# sprite update and the camera move below.
	var part_of_throng_moved = false
	for result in result_array:
		if result:
			part_of_throng_moved = true
			break
	if part_of_throng_moved:
		#await get_tree().physics_frame
		#var tween = get_tree().create_tween()
		#tween.tween_property(self, 'position', self.position + move, 1)
		#await get_tree().create_timer(0.1).timeout
		##call_deferred('move', move)
		self.position += move

func move(move_by: Vector2):
	self.position += move_by

func add(individual: Node):
	if not individual.get_meta('individual'):
		return
	individual.add_to_group(self.throng_id)
