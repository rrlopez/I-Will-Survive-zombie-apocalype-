class_name MapState extends Control
## MapState — fullscreen map overlay. Pauses tree. Drag to pan.

var _drag_start: Vector2 = Vector2.ZERO
var _is_dragging: bool   = false

@onready var _map_view: Control = $MapView

func _enter_tree() -> void:
	get_tree().paused = true
	# Set player marker position if player exists
	if Globals.player and _map_view.has_node("PlayerMarker"):
		_map_view.get_node("PlayerMarker").position = Globals.player.global_position * 0.1

func _exit_tree() -> void:
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or event is InputEventMouseMotion:
		if _is_dragging:
			_map_view.position += event.relative

	if event is InputEventScreenTouch:
		_is_dragging = event.pressed
	elif event is InputEventMouseButton:
		_is_dragging = event.pressed

func _on_btn_close_pressed() -> void:
	Globals.state_manager.pop_overlay()
