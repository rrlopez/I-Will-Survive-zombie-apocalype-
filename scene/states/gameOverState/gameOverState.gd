extends Node2D

func _ready():
	Serialize.saveGame()

func _on_pauseState_tree_entered():
	get_tree().paused = true
	add_child(Globals.stateManager.currentStates[1])



func _on_ReviveBtn_pressed():
	Globals.player.revive()
	get_tree().paused = false
	remove_child(Globals.stateManager.currentStates[1])
	Globals.stateManager.popState()
