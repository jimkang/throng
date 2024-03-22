class_name Alligator extends Individual

func take_turn(event):
	super.take_turn(event)
	var tile_size = $/root/throng_root_node.tile_size
	self.move([Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].pick_random() * tile_size)

func act_on_other(other: Individual):
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