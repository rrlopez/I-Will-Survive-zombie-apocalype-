class_name Zone extends Area2D
## Outdoor daily spawn zone. Active only when parent chunk is ACTIVE.
## Full spawn implementation in Phase 17.

@export var enemy_density: String = "medium"
@export var spawn_radius: float = 400.0

var _is_active: bool = false


## Called by the chunk's _on_activated().
func on_chunk_activated() -> void:
	_is_active = true
	if EventBus.day_started.is_connected(_on_day_started):
		return
	EventBus.day_started.connect(_on_day_started)


## Called by the chunk's _on_deactivated().
func on_chunk_deactivated() -> void:
	_is_active = false
	if EventBus.day_started.is_connected(_on_day_started):
		EventBus.day_started.disconnect(_on_day_started)


func _on_day_started(_day_number: int) -> void:
	if not _is_active:
		return
	# Phase 17: spawn enemies within spawn_radius using enemy_density
	pass
