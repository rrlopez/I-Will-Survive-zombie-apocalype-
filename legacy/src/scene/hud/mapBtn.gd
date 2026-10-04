extends TouchScreenButton



func _on_mapBtn_pressed():
	Globals.stateManager.pushState("mapState")
