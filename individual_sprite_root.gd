class_name IndividualSpriteRoot
extends Node2D

@export var draw_throng_indicator: bool = false
@export var throng_color: Color
@onready var sprite_default: Sprite2D = $sprite_default
var sprite_facing: Sprite2D
var facing_direction: Vector2i

func _draw():
	if self.draw_throng_indicator:
		var sprite = sprite_facing if sprite_facing else sprite_default
		var indicator_rect = sprite.get_rect()
		indicator_rect.position *= sprite.scale
		indicator_rect.size *= sprite.scale
		self.draw_rect(indicator_rect, self.throng_color, false, 2.0)
	if self.facing_direction:
		print('ok') 

func face(direction: Vector2i):
	self.facing_direction = direction
	print('Changing facing dir with sprite: ', self.name)
	var facing_sprite_name = 'sprite_facing_%s' % Geometry.name_for_direction(self.facing_direction)
	print('facing_sprite:', facing_sprite_name)
	var facing_sprite_is_visible = false
	var facing_sprite = Hierarchy.make_only_visible_sibling(self,
	facing_sprite_name)
	
	if facing_sprite:
		facing_sprite_is_visible = true
		self.sprite_facing = facing_sprite		
	if not facing_sprite_is_visible:
		var sprite = self.find_child('sprite_default', false, false)
		if sprite:
			sprite.visible = true
