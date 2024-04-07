class_name Hierarchy
extends Object

static func find_obj(array: Array, test: Callable):
	var filtered = array.filter(test)
	if filtered.size() > 0:
		return filtered[0]

# Returns false if a should come before b.
static func compare_leftward(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.x < b.position.x
	# If a is left of b, return false to make it get sorted first.
	
static func compare_rightward(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.x > b.position.x

static func compare_init(a, b):
	return a.initiative < b.initiative

static func compare_topwise(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	return a.position.y < b.position.y
	
static func compare_bottomwise(a: Node, b: Node) -> bool:
	assert(a is Node2D)
	assert(b is Node2D)
	print(a.position, ' and ', b.position, ' result', a.position.y > b.position.y)
	return a.position.y > b.position.y

# If an animation with either {base_name}_{modifier} or {base_name} exists in 
# the given mixer, this will return its name. It will return null if it can't
# find it.
static func find_animation_name(mixer: AnimationMixer, base_name: String,
modifier: String):
	var animation_name = null
	var modifier_animation_name = base_name + '_' + modifier
	if mixer.get_animation(modifier_animation_name):
		animation_name = modifier_animation_name
	elif mixer.get_animation(base_name):
		animation_name = base_name
	return animation_name

# If a child with either {base_name}_{modifier} or {base_name} exists in 
# the given parent, this will return its name. It will return null if it can't
# find it.
static func find_child_with_fallback(parent: Node, base_name: String,
modifier: String) -> Node:
	var modifier_node_name = base_name + '_' + modifier
	var child = parent.find_child(modifier_node_name, false, false)
	if not child:
		child = parent.find_child(base_name, false, false)
	return child

# Returns the target sprite object.
static func make_only_visible_sibling(parent: Node, target_sprite_name: String) -> Sprite2D:
	# sprite_root isn't going to be owned, so the fourth param here is important.
	var sprites = parent.find_children('*', 'Sprite2D', false, false)
	var target_sprite
	for sprite in sprites:
		if sprite.name == target_sprite_name:
			target_sprite = sprite
			sprite.visible = true
		else:
			sprite.visible = false
	return target_sprite
