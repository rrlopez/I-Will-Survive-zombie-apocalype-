extends Node2D

func _ready():
	Serialize.saveGame()

func _on_gameOverState_tree_entered():
	get_tree().paused = true
	
func _on_ReviveBtn_pressed():
	get_tree().paused = false
	Globals.player.revive()
	yield(get_tree(),"idle_frame")
	Globals.stateManager.remove_child(self)

