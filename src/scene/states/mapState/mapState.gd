extends Node2D

export(NodePath) onready var playerMark = get_node(playerMark) as Sprite
export(NodePath) onready var camera = get_node(camera) as Camera2D

onready var extents = Globals.currentMap.collider.shape.extents
var last_mouse_position
var sensitivity = 20

func _on_CloseBtn_pressed():
	get_tree().paused = false
	yield(get_tree(),"idle_frame")
	Globals.stateManager.remove_child(self)


func _on_map_tree_entered():
	get_tree().paused = true
	yield(get_tree(), "idle_frame")
	playerMark.global_position = Vector2(Globals.player.global_position)
	playerMark.global_rotation_degrees = Globals.player.global_rotation_degrees
	setCameraPosition(playerMark.global_position)
	
func setCameraPosition(position):
	camera.position.x = clamp(position.x, -extents.x, extents.x)
	camera.position.y = clamp(position.y, -extents.y, extents.y)
	
func _on_Control_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			last_mouse_position = event.position
	
	elif event is InputEventScreenDrag:
			setCameraPosition(camera.position-(event.position-last_mouse_position)*sensitivity)
			last_mouse_position = event.position
