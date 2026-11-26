extends BossBase
## Kappa that the player can push around. Shoving it sloshes water out of
## the bowl on its head; floating in a "water"-group Area2D refills it.

signal water_changed(level: float)  # 0.0 empty .. 1.0 full
signal emptied                      # fired once when the bowl runs dry

@export var max_push_speed := 90.0
@export var shove_fade := 4.0  # higher = a shove dies out sooner
@export var drain_per_second := 0.15  # tank lost while being shoved (full -> empty in ~7 s)
@export var refill_per_second := 0.4  # tank gained while in the lake (~2.5 s to full)
@export var windup_time := 0.5;
@export_group("Leap")
## How high the sprites ride during the hop (purely visual; the body stays on the ground).
@export var jump_height: float = 24.0
## Seconds spent rising to the apex (short = snappy hop up).
@export var jump_up_time: float = 0.3
## Seconds spent falling back down (long = slow drift down).
@export var jump_down_time: float = 0.6
## Distance kept between the landing spot and the player. Closer than
## this, the kappa just hops in place.
@export var land_offset: float = 24.0
## Seconds to wait on the ground between leaps.
@export var leap_cooldown: float = 1.0
## Curve/easing of the rise and fall, tweakable in the inspector.
@export var up_trans: Tween.TransitionType = Tween.TRANS_QUAD
@export var up_ease: Tween.EaseType = Tween.EASE_OUT
@export var down_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var down_ease: Tween.EaseType = Tween.EASE_IN_OUT

var start_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var is_leaping := false
var _leap_cooldown_left := 0.0
var _leap_tween: Tween



var water_level := 1.0
var _shove := Vector2.ZERO

@onready var _visuals: Node2D = $Visuals
@onready var bowl_water: Polygon2D = $Visuals/BowlWater
@onready var water_sensor: Area2D = $WaterSensor

const LARGE_SPLASH := preload("res://systems/Yokais/kappa/LargeSplash.tscn")
const SMALL_SPLASH := preload("res://systems/Yokais/kappa/SmallSpash.tscn")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

## Called by the player when it collides with us. Strength = player speed.
func push(direction: Vector2, strength: float) -> void:
	_shove = direction.normalized() * minf(strength, max_push_speed)

func _set_level(value: float) -> void:
	var new_level := clampf(value, 0.0, 1.0)
	if is_equal_approx(new_level, water_level):
		return
	water_level = new_level
	water_changed.emit(water_level)
	if water_level <= 0.0:
		emptied.emit()

func _in_water() -> bool:
	for area in water_sensor.get_overlapping_areas():
		if area.is_in_group("water"):
			return true
	return false

func _idle(_delta: float) -> void:
	pass;
	
func _attack(_delta: float) -> void:
	pass;
	
func _chase(delta: float) -> void:
	if is_leaping:
		return
	## Wait out the cooldown, then hop at the player again
	_leap_cooldown_left -= delta
	if _leap_cooldown_left > 0.0:
		return
	start_leap()

func on_pushed() -> void:
	pass;

func start_leap() -> void:
	if is_leaping:
		return
	start_pos = global_position
	var to_player := player.global_position - start_pos
	## Land a little short of the player; if they're that close already,
	## just do a nervous hop in place instead of landing on top of them.
	if to_player.length() > land_offset:
		target_pos = player.global_position - to_player.normalized() * land_offset
	else:
		target_pos = start_pos

	is_leaping = true
	## Rise fast (ease out off the ground), hang at the apex, settle down slowly
	
	_leap_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	#_leap_tween.tween_callback(_play_windup)
	_leap_tween.tween_interval(windup_time)   # the 1-second pause
	_leap_tween.tween_callback(_splash.bind(false))
	_leap_tween.tween_method(_leap_step, 0.0, 0.5, jump_up_time) \
		.set_trans(up_trans).set_ease(up_ease)
	_leap_tween.tween_method(_leap_step, 0.5, 1.0, jump_down_time) \
		.set_trans(down_trans).set_ease(down_ease)
	_leap_tween.tween_callback(_finish_leap)

## Slides the body from start_pos to target_pos while the sprites ride a sine
## height arc, so the hop reads as a leap towards the player (the game is
## top-down, so world-space -Y would just drift it up the screen). Feeds the
## motion through velocity so move_and_slide() still collides mid-leap.
func _leap_step(t: float) -> void:
	velocity = (start_pos.lerp(target_pos, t) - global_position) / get_physics_process_delta_time()
	_visuals.position.y = -jump_height * sin(t * PI)

func _finish_leap() -> void:
	is_leaping = false
	velocity = Vector2.ZERO
	_visuals.position.y = 0.0
	_leap_cooldown_left = leap_cooldown
	
func _splash(big: bool) -> void:
	var fx: AnimatedSprite2D = (LARGE_SPLASH if big else SMALL_SPLASH).instantiate()
	fx.global_position = global_position
	get_parent().add_child(fx)   # world, not self — splash survives the kappa moving/dying
