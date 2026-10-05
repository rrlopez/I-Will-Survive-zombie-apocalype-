extends Node
## Serialize — threaded JSON save / load.
## Phase 0 stub: API shape is final; full implementation in Phase 14.

const SAVE_PATH := "user://savegame.json"

var _thread: Thread

func _ready() -> void:
	_thread = Thread.new()
	tree_exiting.connect(_on_tree_exiting)


# ── Public API ────────────────────────────────────────────────────────────────

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	# Phase 14 will collect serializable nodes and write to disk on a thread.
	push_warning("Serialize.save_game: not yet implemented (Phase 14)")


func load_game() -> void:
	# Phase 14 will read the JSON and rebuild the scene state.
	push_warning("Serialize.load_game: not yet implemented (Phase 14)")


# ── Cleanup ───────────────────────────────────────────────────────────────────

func _on_tree_exiting() -> void:
	if _thread.is_started():
		_thread.wait_to_finish()
