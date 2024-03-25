class_name Alligator extends Individual

var cardinal_directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func take_turn(event):
	super.take_turn(event)
	if (self.rng.randi_range(0, 3) > 2):
		return

	var tile_size = $/root/throng_root_node.tile_size
	self.move(BasicUtils.pick_random(self.cardinal_directions, self.rng) * tile_size)

func act_on_other(other: Individual):
	# NEXT: Look into why alligator is sometimes on top of another individual.
	var turn_over = bite(other)
	if !turn_over:
		super.act_on_other(other)

func bite(bitee: Individual):
	self.sprite_presenter.queue_presentable(SpritePresenter.Presentable.new(
		self.animation_op, [self.sprite_root.get_node('AnimationPlayer'), 'chomp']
	))
	bitee.die()
	return true

func _to_string():
	return 'Alligator_' + self.name
