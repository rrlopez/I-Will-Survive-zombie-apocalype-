class_name ChunkBase extends Node2D
## Base script for all chunk scenes.
## Chunk scenes assign chunk_coord before add_child().
## activate() / deactivate() are called by ChunkStreamer.
## Override _on_activated() / _on_deactivated() in subclasses (Phase 17).

## Chunk grid coordinate (set by ChunkStreamer before adding to tree).
var chunk_coord: Vector2i = Vector2i.ZERO


## Called by ChunkStreamer after nav bake completes.
func activate() -> void:
	set_process_mode(PROCESS_MODE_INHERIT)
	_on_activated()


## Called by ChunkStreamer when the chunk leaves the active ring.
func deactivate() -> void:
	set_process_mode(PROCESS_MODE_DISABLED)
	_on_deactivated()


## Override in subclasses to start spawners, connect day signal, etc.
func _on_activated() -> void:
	pass


## Override in subclasses to stop spawners, disconnect signals, etc.
func _on_deactivated() -> void:
	pass
