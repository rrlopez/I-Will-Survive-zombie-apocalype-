class_name Vehicle_controller extends Control


signal use_disembark
signal use_rotateArea_degrees
signal use_rotateArea_released

signal use_accelerate
signal use_break


var last_mouse_position = Vector2.ZERO
var rotation_sensitivity = 100
var rotated = 0

var rotateAreaPressed


func _input(event):
	if(event is InputEventKey):
		if event.is_action_pressed("ui_up"): _on_AccelerateBtn_pressed()
		elif event.is_action_released("ui_up"): _on_AccelerateBtn_released()
		if event.is_action_pressed("ui_down"): _on_BreakBtn_pressed()
		elif event.is_action_released("ui_down"):  _on_BreakBtn_released()
		

func _on_Control_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed() and event.position.x > Constants.WIDTH/2:
			last_mouse_position = event.position
			rotateAreaPressed = event.index
		else:
			rotated = 0
			rotateAreaPressed = null
			emit_signal('use_rotateArea_released')
	
	elif event is InputEventScreenDrag and rotateAreaPressed == event.index:
		rotated = last_mouse_position.x-event.position.x
		emit_signal('use_rotateArea_degrees', rotated)

			

func _on_AccelerateBtn_pressed():
	emit_signal('use_accelerate', true)

func _on_AccelerateBtn_released():
	emit_signal('use_accelerate', false)


func _on_BreakBtn_pressed():
	emit_signal('use_break', true)


func _on_BreakBtn_released():
	emit_signal('use_break', false)


func _on_disembarkBtn_pressed():
	emit_signal('use_disembark')
