class_name Throng
extends Node2D

@export var move_size: int 
@export var throng_id: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	handle_move()

func handle_move():
	var x = 0
	var y = 0
	if Input.is_action_just_released("ui_left"):
		x -= 1
	if Input.is_action_just_released("ui_right"):
		x += 1
	if Input.is_action_just_released("ui_up"):
		y -= 1
	if Input.is_action_just_released("ui_down"):
		y += 1

	if x != 0 or y != 0:
		var move = Vector2(x * move_size, y * move_size)
		var result_array = []
		get_tree().call_group(self.throng_id, 'move', move, result_array)
		print('move_results: ', result_array)
		var part_of_throng_moved = false
		for result in result_array:
			if result:
				part_of_throng_moved = true
				break
		if part_of_throng_moved:
			self.position += move

func add(individual: Node):
	if not individual.get_meta('individual'):
		return
	individual.add_to_group(self.throng_id)
