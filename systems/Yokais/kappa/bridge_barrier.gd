extends BossBarrier

@export var bridge: TileMapLayer;

func activate() -> void:
	bridge.collision_enabled = false
	create_tween().tween_property(bridge, "modulate:a", 0.0, 0.6)
	
func deactivate() -> void:
	bridge.collision_enabled = true
	create_tween().tween_property(bridge, "modulate:a", 1, 0.6)
