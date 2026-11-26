class_name OneShotFX
extends AnimatedSprite2D
## Plays its animation once, then deletes itself.
## The sprite frames must have Loop disabled or it never frees.

@export var animation_name: StringName = &"default"

func _ready() -> void:
	play(animation_name)
	animation_finished.connect(queue_free)
