class_name LoadingState extends Control
## LoadingState — overlay shown while initial chunks load.
## Pauses tree but keeps physics active for nav polygon baking.
## Dismisses itself once ChunkStreamer reports initial load complete.

@onready var _spinner: Label = $Spinner
var _timer: float = 0.0
const MIN_DISPLAY_TIME := 0.3   ## avoid flicker on very fast loads


func _enter_tree() -> void:
	get_tree().paused = true
	PhysicsServer2D.set_active(true)
	EventBus.chunk_activated.connect(_on_chunk_event)
	# Check immediately in case world is tiny and already done.
	_check_done()


func _exit_tree() -> void:
	get_tree().paused = false
	if EventBus.chunk_activated.is_connected(_on_chunk_event):
		EventBus.chunk_activated.disconnect(_on_chunk_event)


func _process(delta: float) -> void:
	_timer += delta
	# Spinning dots animation
	var dots := ".".repeat(int(_timer * 3.0) % 4)
	_spinner.text = "Loading" + dots


func _on_chunk_event(_coord: Vector2i) -> void:
	_check_done()


func _check_done() -> void:
	if _timer < MIN_DISPLAY_TIME:
		return
	if ChunkStreamer.is_initial_load_complete():
		Globals.state_manager.pop_overlay()
