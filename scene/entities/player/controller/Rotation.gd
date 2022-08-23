extends Control

signal use_rotateArea_degrees

export(NodePath) onready var controller = get_node(controller) as Node2D

var last_mouse_position = Vector2.ZERO
var rotation_sensitivity = 100
var rotated = 0

var rotateAreaPressed

func _on_Rotation_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if event.position.x > Constants.WIDTH/2:
				rotateAreaPressed = event.index
				last_mouse_position = event.position
		elif rotateAreaPressed==event.index:
				rotateAreaPressed = null
	
	
	elif event is InputEventScreenDrag and rotateAreaPressed==event.index:
		var rotation_offset = (last_mouse_position.x-event.position.x) + (last_mouse_position.y-event.position.y)
		rotated = fmod(rotated + rotation_offset, 360)
		last_mouse_position = event.position
		controller.emit_signal('use_rotateArea_degrees', rotated)
