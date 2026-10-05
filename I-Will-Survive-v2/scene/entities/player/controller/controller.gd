class_name PlayerController extends Control
## PlayerController — full-screen touch + keyboard input handler.
##
## Screen zones:
##   Left zone  (≤ 45% screen width) → virtual joystick → move_input_changed
##   Right zone (> 45% screen width) → drag = rotation_input, tap = fire action
##
## Signals are consumed by Player (or Vehicle in Phase 13) via direct connection.
## The controller never references the player directly — pure signal emitter.

# ── Signals ───────────────────────────────────────────────────────────────────
signal move_input_changed(direction: Vector2)   ## normalized screen-space direction
signal rotation_input(delta_angle: float)       ## radians to add to player facing
signal action_pressed(action: StringName)       ## "fire", "reload", "interact", "disembark"
signal action_released(action: StringName)

# ── Joystick state ────────────────────────────────────────────────────────────
var _joystick_active: bool      = false
var _joystick_origin: Vector2   = Vector2.ZERO  ## screen pos where touch began
var _joystick_index: int        = -1            ## touch finger index

# ── Right zone state ──────────────────────────────────────────────────────────
var _right_touch_index: int      = -1
var _right_touch_origin: Vector2  = Vector2.ZERO
var _right_touch_start_pos: Vector2 = Vector2.ZERO
var _right_touch_time: float     = 0.0
var _mouse_dragging: bool        = false   ## true while right mouse button held
var _mouse_last_pos: Vector2     = Vector2.ZERO
const TAP_MAX_TIME: float        = 0.2
const TAP_MAX_MOVE: float        = 10.0

# ── Joystick visual nodes (optional — present if scene has them) ──────────────
@onready var _joystick_base: Control  = get_node_or_null("JoystickBase")
@onready var _joystick_knob: Control  = get_node_or_null("JoystickBase/Knob")

# ── Setup ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0
	mouse_filter  = Control.MOUSE_FILTER_PASS   # must PASS to receive mouse motion

	if _joystick_base:
		_joystick_base.hide()

# ── Input ─────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	# ── Keyboard (desktop fallback) ───────────────────────────────────────────
	if event is InputEventKey:
		_handle_key(event as InputEventKey)
		return

	# ── Mouse button (desktop fire / rotate) ─────────────────────────────────
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				action_pressed.emit(&"fire")
			else:
				action_released.emit(&"fire")
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			_mouse_dragging = mb.pressed
			_mouse_last_pos = mb.position
		return

	# ── Mouse motion (desktop drag-to-rotate) ─────────────────────────────────
	if event is InputEventMouseMotion:
		if _mouse_dragging:
			var mm := event as InputEventMouseMotion
			var delta_angle := mm.relative.x * Constants.DRAG_SENSITIVITY * 0.25
			rotation_input.emit(delta_angle)
		return

	# ── Touch ─────────────────────────────────────────────────────────────────
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_drag(event as InputEventScreenDrag)


func _process(delta: float) -> void:
	# Continuous Q/E rotation — large enough to feel responsive on desktop
	var rot_speed := Constants.ROTATION_SPEED * 0.25 * delta
	if Input.is_key_pressed(KEY_Q):
		rotation_input.emit(-rot_speed)
	if Input.is_key_pressed(KEY_E):
		rotation_input.emit(rot_speed)

	# Accumulate right-zone tap timer
	if _right_touch_index != -1:
		_right_touch_time += delta

# ── Touch handlers ────────────────────────────────────────────────────────────

func _handle_touch(event: InputEventScreenTouch) -> void:
	var pos := event.position
	var screen_w := float(get_viewport_rect().size.x)
	var in_left_zone := pos.x <= screen_w * 0.45

	if event.pressed:
		if in_left_zone and _joystick_index == -1:
			# Start joystick
			_joystick_index  = event.index
			_joystick_origin = pos
			_joystick_active = true
			if _joystick_base:
				_joystick_base.position = pos - _joystick_base.size * 0.5
				_joystick_base.show()
		elif not in_left_zone and _right_touch_index == -1:
			# Start right-zone tracking
			_right_touch_index    = event.index
			_right_touch_origin   = pos
			_right_touch_start_pos = pos
			_right_touch_time     = 0.0
	else:
		if event.index == _joystick_index:
			# Release joystick
			_joystick_index  = -1
			_joystick_active = false
			if _joystick_base:
				_joystick_base.hide()
			move_input_changed.emit(Vector2.ZERO)

		elif event.index == _right_touch_index:
			# Release right zone — check if it was a tap (fire)
			var moved := event.position.distance_to(_right_touch_start_pos)
			if _right_touch_time <= TAP_MAX_TIME and moved <= TAP_MAX_MOVE:
				action_pressed.emit(&"fire")
				action_released.emit(&"fire")
			_right_touch_index = -1


func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == _joystick_index:
		# Joystick movement
		var offset := event.position - _joystick_origin
		if offset.length() < Constants.JOYSTICK_DEAD_ZONE:
			move_input_changed.emit(Vector2.ZERO)
			_update_knob(Vector2.ZERO)
			return
		var clamped := offset.limit_length(Constants.JOYSTICK_MAX_RADIUS)
		var direction := clamped.normalized()
		move_input_changed.emit(direction)
		_update_knob(clamped)

	elif event.index == _right_touch_index:
		# Right zone drag → rotation
		var delta_angle := event.relative.x * Constants.DRAG_SENSITIVITY
		rotation_input.emit(delta_angle)

# ── Keyboard handlers ─────────────────────────────────────────────────────────

func _handle_key(event: InputEventKey) -> void:
	if event.echo:
		return

	# R key → reload action
	if event.pressed and event.physical_keycode == KEY_R:
		action_pressed.emit(&"reload")

	# Movement keys — rebuild direction on every press or release
	match event.physical_keycode:
		KEY_W, KEY_UP, KEY_S, KEY_DOWN, KEY_A, KEY_LEFT, KEY_D, KEY_RIGHT:
			var dir := Vector2.ZERO
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):    dir.y -= 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):  dir.y += 1.0
			if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):  dir.x -= 1.0
			if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir.x += 1.0
			move_input_changed.emit(dir.normalized())

# ── Helpers ───────────────────────────────────────────────────────────────────

func _update_knob(offset: Vector2) -> void:
	if _joystick_knob:
		_joystick_knob.position = offset
