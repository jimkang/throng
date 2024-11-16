class_name LevelContentsRoot
extends Node

var individual_scene = preload('res://individual.tscn')
var alligator_scene = preload('res://individual_alligator.tscn')
var exit_scene = preload('res://gdrl-shared/exit.tscn')
var rng
var tile_size
@onready var liminal_space: LiminalSpace = $"../liminal_space"

func depopulate_level():
	var non_permanent_children = BasicUtils.filter(
		self.get_children(),
		func(child: Node): return !child.get_meta('permanent')
	)
	non_permanent_children.map(self.delete_child)
	# We need to wait for these deletes to take place before moving on.
	await self.get_tree().physics_frame

func delete_child(node: Thing):
	node.remove_visual_representation()
	self.remove_child(node)
	node.queue_free()

func populate_level(possible_individual_locations: Array):
	for i in 15:
		var indiv_scene = individual_scene
		if rng.randi_range(0, 1) > 0:
			indiv_scene = alligator_scene
		self.generate_at_random_place(indiv_scene, i, possible_individual_locations)

	self.generate_at_random_place(exit_scene, 0, possible_individual_locations)

	return possible_individual_locations

func generate_at_random_place(thing_scene, name_index, locations):
	var thing = thing_scene.instantiate()
	thing.rng = self.rng
	if name_index > -1:
		thing.readable_name = '%s_%d' % [thing.name, name_index]
	return add_at_random_place(thing, locations)

# Mutates locations.
func add_at_random_place(thing, locations):
	self.add_child(thing)
	var location = Vector2(BasicUtils.pop_random(locations, self.rng))
	return self.move_to_place(thing, location)

# Location is not a position! It's a grid coordinate.
func move_to_place(thing, location):
	thing.face_direction(Vector2i.DOWN)
	thing.change_position(MapLib.spot_to_position(location, tile_size))
	return thing

func _on_child_exiting_tree(node):
	if node.is_in_group('throng_player'):
		self.liminal_space.call_deferred('check_for_level_completion')
