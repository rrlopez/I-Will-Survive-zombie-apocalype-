extends Node2D


func _on_TouchScreenButton_pressed():
	get_tree().paused = false
	remove_child(Globals.stateManager.currentStates[1])
	Globals.stateManager.popState()


func _on_pauseState_tree_entered():
	get_tree().paused = true
	add_child(Globals.stateManager.currentStates[1])

