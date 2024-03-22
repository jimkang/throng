class_name Alligator extends Individual

# Next: Decide on this inheritance situation with AnimatedSprite2d.
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
