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
		self.position += move
		get_tree().call_group(self.throng_id, 'move', move)

func add(individual: Node):
	if not individual.get_meta('individual'):
		return
	individual.add_to_group(self.throng_id)
