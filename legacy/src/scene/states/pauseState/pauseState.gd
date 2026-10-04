extends CanvasLayer

export(NodePath) onready var tween  = get_node(tween) as Tween


func _on_ResumeBtn_pressed():
	yield(get_tree(),"idle_frame")
	tween.connect("tween_all_completed", self, "leaved", [], CONNECT_ONESHOT)
	tween.interpolate_property($ColorRect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func leaved():
	get_tree().paused = false
	Globals.stateManager.remove_child(self)
	Globals.stateManager.transition.pause_mode = PAUSE_MODE_INHERIT
	
func _on_pauseState_tree_entered():
	get_tree().paused = true
	yield(get_tree(),"idle_frame")
	tween.interpolate_property($ColorRect, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func _on_QuitBtn_pressed():
	Globals.stateManager.transition.pause_mode = PAUSE_MODE_PROCESS
	Globals.stateManager.connect("stateReady", self, "leaved", [], CONNECT_ONESHOT)
	Globals.stateManager.popState()




