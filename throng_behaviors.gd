class_name ThrongBehaviors
extends Object

static func can_recruit(recruiter: Node, recruitee: Node) -> bool:
	var groups = recruitee.get_groups()
	var is_in_a_throng = groups.any(func (group): return group.begins_with('throng_'))
	if not is_in_a_throng:
		var throng = get_throng_of_individual(recruiter)
		return true
	return false

static func recruit(recruiter: Node, recruitee: Node):
	if can_recruit(recruiter, recruitee):
		var throng = get_throng_of_individual(recruiter)
		throng.add(recruitee)
		return Thing.ActionOutcome.recruited
	return Thing.ActionOutcome.no_move

static func get_throng_id(individual: Node):
	var groups = individual.get_groups().filter(func (group: String): return group.begins_with('throng_'))
	if groups.size() > 0:
		assert(groups.size() == 1)
		return groups[0]

static func get_throng_of_individual(indiv) -> Throng:
	var root = indiv.get_node('/root/game_root')
	var self_throng_id = get_throng_id(indiv)
	return Hierarchy.find_obj(
		root.get_children(),
		func(obj): return obj.name == 'throng' and obj.throng_id == self_throng_id
	)
