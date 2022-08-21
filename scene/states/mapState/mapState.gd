extends ColorRect

export(NodePath) onready var playerMark = get_node(playerMark) as Sprite


func _on_CloseBtn_pressed():
	Globals.stateManager.popState()


func _on_map_tree_entered():
	yield(get_tree(), "idle_frame")
	playerMark.global_position = Vector2(Globals.player.global_position)
	playerMark.rotation_degrees = Globals.player.rotation_degrees
