extends Node
## Debug camera controls - attach to any node in your scene.
## Mouse wheel = zoom in/out
## Hold SHIFT = move camera freely

var camera: Camera2D = null
var original_parent: Node = null
var free_camera_mode := false

func _ready() -> void:
	# Find the camera
	await get_tree().create_timer(0.2).timeout
	
	if Globals.player and is_instance_valid(Globals.player):
		camera = Globals.player.get_node_or_null("Camera2D")
		if camera:
			original_parent = camera.get_parent()
			print("Debug camera controls enabled:")
			print("  Mouse Wheel = Zoom")
			print("  SHIFT + WASD = Free camera")
			print("  ESC = Reset camera")

func _input(event: InputEvent) -> void:
	if not camera:
		return
	
	# Zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
			print("Camera zoom: ", camera.zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
			print("Camera zoom: ", camera.zoom)
	
	# Toggle free camera with SHIFT
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SHIFT:
			toggle_free_camera()
		elif event.keycode == KEY_ESCAPE:
			reset_camera()

func _process(delta: float) -> void:
	if not camera or not free_camera_mode:
		return
	
	# Free camera movement
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): move.y -= 1
	if Input.is_key_pressed(KEY_S): move.y += 1
	if Input.is_key_pressed(KEY_A): move.x -= 1
	if Input.is_key_pressed(KEY_D): move.x += 1
	
	if move != Vector2.ZERO:
		camera.global_position += move.normalized() * 500 * delta

func toggle_free_camera() -> void:
	if not camera:
		return
	
	free_camera_mode = not free_camera_mode
	
	if free_camera_mode:
		# Detach camera from player
		var pos = camera.global_position
		var cam_parent = camera.get_parent()
		cam_parent.remove_child(camera)
		get_tree().root.add_child(camera)
		camera.global_position = pos
		camera.enabled = true
		print("FREE CAMERA MODE - Use WASD to move, Mouse wheel to zoom")
	else:
		# Reattach to player
		var pos = camera.global_position
		camera.get_parent().remove_child(camera)
		original_parent.add_child(camera)
		camera.position = Vector2.ZERO
		camera.enabled = true
		print("CAMERA LOCKED TO PLAYER")

func reset_camera() -> void:
	if not camera:
		return
	
	camera.zoom = Vector2.ONE
	free_camera_mode = false
	
	# Ensure attached to player
	if camera.get_parent() != original_parent and original_parent:
		camera.get_parent().remove_child(camera)
		original_parent.add_child(camera)
		camera.position = Vector2.ZERO
	
	print("Camera reset to default")
