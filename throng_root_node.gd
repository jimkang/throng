extends Node2D

#var dungeon_tile_set = preload('res://throng_dungeon_tile_set.tres').instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generate_map():
	var tilemap = $dungeon_tilemap
	tilemap.add_layer(0)
	tilemap.set_cell(0, Vector2i(3, 3), 0, Vector2i(14, 17))
