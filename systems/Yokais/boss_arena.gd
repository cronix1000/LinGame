class_name BossArena
extends Node2D

@export var barrier: BossBarrier
@export var boss: BossBase
@onready var entrance : Area2D

signal boss_fight_started;
signal boss_fight_ended;

var _fight_active := false

#@onready var _ui_layer: CanvasLayer = $UILayer

func _start_fight() -> void:
	if _fight_active:
		return;
	_fight_active = true;
	boss._fight_started()
	barrier.activate();
	print("hit")
	#_spawn_ui();

func _end_fight() -> void:
	if not _fight_active:
		return;
	_fight_active = false
	barrier.deactivate();

func _on_aggro_zone_body_entered(body: Node2D) -> void:
	print("hit")
	if body.is_in_group("player") and not _fight_active:
		_start_fight()
