class_name IndividualSpriteRoot
extends Node2D

@export var draw_throng_indicator: bool = false
@export var throng_color: Color
@onready var sprite: Sprite2D = $Sprite2D

func _draw():
	if self.draw_throng_indicator:
		var indicator_rect = sprite.get_rect()
		indicator_rect.position *= sprite.scale
		indicator_rect.size *= sprite.scale
		self.draw_rect(indicator_rect, self.throng_color, false, 2.0)

func free_sprite_root_op():
	self.queue_free()
