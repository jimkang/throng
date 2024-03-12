extends Node2D

@export var move_size: int 

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

	var move = Vector2(x * move_size, y * move_size)
	var screen_size = get_window().size
	self.position += move
	self.position.x = clamp(self.position.x, 0, screen_size.x)
	self.position.y = clamp(self.position.y, 0, screen_size.y)
