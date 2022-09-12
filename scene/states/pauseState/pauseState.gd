extends Node2D



func _on_TouchScreenButton_pressed():
	get_tree().paused = false
	yield(get_tree(),"idle_frame")
	Globals.stateManager.remove_child(self)
	Globals.stateManager.transition.pause_mode = PAUSE_MODE_INHERIT


func _on_pauseState_tree_entered():
	get_tree().paused = true



func _on_QuitBtn_pressed():
	Globals.stateManager.transition.pause_mode = PAUSE_MODE_PROCESS
	Globals.stateManager.connect("stateReady", self, "_on_TouchScreenButton_pressed", [], CONNECT_ONESHOT)
	Globals.stateManager.popState()
