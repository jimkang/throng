class_name Alligator extends Individual

var cardinal_directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func take_turn(event):
	super.take_turn(event)
	if (self.rng.randi_range(0, 3) > 2):
		return

	var tile_size = $/root/throng_root_node.tile_size
	self.move(BasicUtils.pick_random(self.cardinal_directions, self.rng) * tile_size)

func act_on_other(other: Individual):
	var turn_over = bite(other)
	if !turn_over:
		super.act_on_other(other)

func bite(bitee: Individual):
	# NEXT: Should turn in that direction to bite.
	var facing_name = Geometry.name_for_direction(self.facing)
	var op_name = self.readable_name + ' biting ' + bitee.readable_name
	
	var anim_root = self.sprite_root.get_node('animation_root')
	var animation_node = Hierarchy.find_child_with_fallback(anim_root,
	'animation_chomp', facing_name)
	assert(animation_node, 'An animation for chomp exists.')
	
	if animation_node:
		self.sprite_presenter.queue_presentable(Presentable.new(op_name,
			Presentable.sprite_animation_op, [self.sprite_root, animation_node],
			true))

	bitee.die()
	return true
		
func _to_string():
	return 'Alligator_' + self.name
