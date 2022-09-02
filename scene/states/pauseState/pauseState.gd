extends Node2D



func _on_TouchScreenButton_pressed():
	get_tree().paused = false
	yield(get_tree(),"idle_frame")
	Globals.stateManager.remove_child(self)


func _on_pauseState_tree_entered():
	get_tree().paused = true

