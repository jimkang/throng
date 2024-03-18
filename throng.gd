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
	
	# Stop _process and draw calls, but keep physics going.
	get_tree().paused = true
	PhysicsServer2D.set_active(true)	
	
	var part_of_throng_moved = false
	var last_individual_did_move = false
	for individual in individuals:
		if last_individual_did_move:
			# We need to wait for the move to take effect so that the next
			# collision calculations take it into account.
			await get_tree().physics_frame
		assert(individual is Individual)
		print('Moving: ', individual.name)
		last_individual_did_move = individual.move(move)
		if !part_of_throng_moved:
			part_of_throng_moved = last_individual_did_move
	
	if part_of_throng_moved:
		self.position += move

	# This delay prevents flicker! I think it makes it so that all of the
	# drawing that needs to be done as a result of the moves above are done
	# in one frame.
	await get_tree().create_timer(0.1).timeout
	# Unpause to get _process and _draw going again.
	get_tree().paused = false

func add(individual: Node):
	if not individual.get_meta('individual'):
		return
	individual.add_to_group(self.throng_id)
