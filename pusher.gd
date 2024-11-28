class_name Pusher
extends Thing

@onready var tile_size = $/root/game_root.tile_size
@onready var tree := self.get_tree()

func take_turn(_event):
	if self.rng.randi_range(0, 3) > 2:
		return

	await self.move(BasicUtils.pick_random(Geometry.cardinal_directions, self.rng) * 
	self.tile_size)

# This is async.
func act_on_other(other: Thing):
	# Push
	# move other guy, move yourself. If there's space.		
	var outcome = await push(other)
	if outcome == ActionOutcome.no_move:
		super.act_on_other(other)

func push(target: Thing):
	# var facing_name = Geometry.name_for_direction(self.facing)
	var move_by_vector = self.facing * self.tile_size
	var pushed = await target.move(move_by_vector, true, false)
	if pushed:
		# Sync physics state so that collisions will be evaluated with the target's
		# post-push position.
		await self.tree.physics_frame
		self.move(move_by_vector, false, true)
	return pushed
