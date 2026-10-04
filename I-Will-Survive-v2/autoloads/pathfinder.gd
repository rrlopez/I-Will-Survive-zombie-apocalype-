extends Node
## Pathfinder — async navigation request queue.
## Phase 0 stub: NavigationAgent2D handles per-enemy pathfinding in Phase 6/7.
## This autoload is kept for compatibility; full batch-threading in Phase 7.

func _ready() -> void:
	# Pathfinder starts inactive; GameState enables it when the world is loaded.
	set_physics_process(false)


## Called by GameState._enter() to activate the pathfinder.
func enable() -> void:
	set_physics_process(true)


## Called by GameState._exit() to deactivate.
func disable() -> void:
	set_physics_process(false)
