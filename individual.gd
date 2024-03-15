extends Node2D

@export var color_set: PackedColorArray

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.modulate = color_set[randi_range(0, color_set.size()-1)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move(move_vector: Vector2):
	self.position += move_vector
