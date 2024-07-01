class_name ThrongBehaviors
extends Object

static func recruit(recruiter: Node, recruitee: Node):
	var groups = recruitee.get_groups()
	var is_in_a_throng = groups.any(func (group): return group.begins_with('throng_'))
	if not is_in_a_throng:
		var root = recruiter.get_node('/root/game_root')
		var self_throng_id = get_throng_id(recruiter)
		var throng: Throng = Hierarchy.find_obj(
			root.get_children(),
			func(obj): return obj.name == 'Throng' and obj.throng_id == self_throng_id
		)
		throng.add(recruitee)

static func get_throng_id(individual: Node):
	var groups = individual.get_groups().filter(func (group: String): return group.begins_with('throng_'))
	if groups.size() > 0:
		assert(groups.size() == 1)
		return groups[0]
