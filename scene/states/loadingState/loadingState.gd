extends Node2D


func _on_loadingState_tree_exiting():
	get_tree().paused = false
	yield(get_tree(),"idle_frame")


func _on_loadingState_tree_entered():
	get_tree().paused = true
	Physics2DServer.set_active(true)
