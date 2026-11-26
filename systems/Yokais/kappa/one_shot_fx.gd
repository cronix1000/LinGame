class_name OneShotVFX
extends AnimatedSprite2D
## Plays its animation once, then deletes itself.
## The SpriteFrames animation must have Loop disabled, or
## animation_finished never fires and the effect never frees.

@export var animation_name: StringName = &"default"

func _ready() -> void:
	play(animation_name)
	animation_finished.connect(queue_free)
