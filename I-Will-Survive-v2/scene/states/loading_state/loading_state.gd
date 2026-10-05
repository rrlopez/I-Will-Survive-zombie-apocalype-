class_name LoadingState extends Control
## LoadingState — overlay shown while chunks load.
## Pauses tree but keeps physics active for nav polygon baking.
## Removes itself when ChunkStreamer signals initial load complete.
## Phase 4 will connect to ChunkStreamer. For now it auto-dismisses after 0.5s
## so Phase 3 can be tested without the world system.

@onready var _spinner: Label = $Spinner
var _timer: float = 0.0
const AUTO_DISMISS := 0.5   ## removed when Phase 4 ChunkStreamer is wired

func _enter_tree() -> void:
	get_tree().paused = true
	PhysicsServer2D.set_active(true)

func _exit_tree() -> void:
	# GameState owns unpausing — we never unpause here
	get_tree().paused = false

func _process(delta: float) -> void:
	_timer += delta
	# Spinning dots animation
	var dots := ".".repeat((int(_timer * 3.0) % 4))
	_spinner.text = "Loading" + dots

	# Auto-dismiss stub — Phase 4 replaces this with ChunkStreamer signal
	if _timer >= AUTO_DISMISS:
		Globals.state_manager.pop_overlay()
