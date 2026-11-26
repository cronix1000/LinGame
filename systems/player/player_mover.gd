extends CharacterBody2D

@export var speed := 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if direction != Vector2.ZERO:
		# Compare horizontal vs vertical intensity to decide the dominant direction
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				animated_sprite.play("male_1_walk_left")
			else:
				animated_sprite.play("male_1_walk_right")
		else:
			if direction.y < 0:
				animated_sprite.play("male_1_walk_forward")
			else:
				animated_sprite.play("male_1_walk_down")
	else:
		# Optional: Play an idle animation when not moving
		animated_sprite.stop() 
	move_and_slide()
	# Shove anything pushable we bumped into (e.g. the kappa)
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is Node and collider.has_method("push"):
			collider.push(-collision.get_normal(), speed)
