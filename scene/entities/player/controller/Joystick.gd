extends Node2D

signal use_joystick_vector
signal on_joystick_release
signal use_rotateArea_degrees



export(NodePath) onready var joystick_texture  = get_node(joystick_texture) as Node2D
export(NodePath) onready var joystick_btn = get_node(joystick_btn) as Sprite

var last_mouse_position = Vector2.ZERO
var rotation_sensitivity = 100
var rotated = 0


var joystickPressed
var rotateAreaPressed

	
func _unhandled_input(event):
	if(event is InputEventKey):
		if event.is_action_pressed("ui_up"): emit_signal('use_joystick_vector', {'key': 'up', 'value': Vector2(0, -1)})
		elif event.is_action_released("ui_up"): emit_signal('on_joystick_release', "up")
		if event.is_action_pressed("ui_down"): emit_signal('use_joystick_vector', {'key': 'down', 'value': Vector2(0, 1)})
		elif event.is_action_released("ui_down"): emit_signal('on_joystick_release', "down")
		if event.is_action_pressed("ui_left"): emit_signal('use_joystick_vector', {'key': 'left', 'value': Vector2(-1, 0)})
		elif event.is_action_released("ui_left"): emit_signal('on_joystick_release', "left")
		if event.is_action_pressed("ui_right"): emit_signal('use_joystick_vector', {'key': 'right', 'value': Vector2(1, 0)})
		elif event.is_action_released("ui_right"): emit_signal('on_joystick_release', "right")
		
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if event.position.x < Constants.WIDTH/3:
				joystickPressed = event.index
				joystick_texture.show()
				joystick_texture.position = event.position
				joystick_btn.position = event.position-joystick_texture.position
			
			if event.position.x > Constants.WIDTH/2:
				rotateAreaPressed = event.index
				last_mouse_position = event.position
		else:
			if joystickPressed==event.index:
				_on_Control_tree_exited()
			if rotateAreaPressed==event.index:
				rotateAreaPressed = null
	
	
	elif event is InputEventScreenDrag:
		if joystickPressed==event.index:
			joystick_btn.position = Vector2(event.position-joystick_texture.position).clamped(70)
			emit_signal('use_joystick_vector', {"key": "touch", "value": joystick_btn.position.normalized()})

		if rotateAreaPressed==event.index:
			var rotation_offset = (last_mouse_position.x-event.position.x) + (last_mouse_position.y-event.position.y)
			rotated = fmod(rotated + rotation_offset, 360)
			last_mouse_position = event.position
			emit_signal('use_rotateArea_degrees', rotated)


func _on_Control_tree_exited():
	joystickPressed = null
	joystick_texture.visible = false
	emit_signal('on_joystick_release', "touch")


func _on_Control_gui_input(event):
	pass

