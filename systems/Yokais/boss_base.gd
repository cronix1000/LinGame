# boss_base.gd
class_name BossBase
extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK, HURT, DOWN }
var state := State.CHASE

signal boss_fight_started;
signal boss_fight_ended;

var _is_fight_active: bool;
@export var player: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent := get_parent()
	if parent and parent.has_signal("fight_started"):
		parent.connect("fight_started", _fight_started);

func _fight_started() -> void:
	state = State.CHASE;

func find_player() -> Node2D:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	return player
		
func _physics_process(delta: float) -> void:
	if not find_player():
		return;
		
	match state:
		State.IDLE: _idle(delta)
		State.CHASE: _chase(delta)
		State.ATTACK: _attack(delta)
	move_and_slide()

func _attack(_delta: float) -> void:  
	pass;

func _chase(_delta: float) -> void:  
	pass;
	
func _idle(_delta: float) -> void:  
	pass;

func _find_player() -> void:
	pass;
