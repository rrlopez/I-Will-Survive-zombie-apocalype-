extends Node2D

func continueGame():
	Serialize.loadGame()
	Globals.player.addCamera()
	pass
	

func newGame():
	createNewPlayer()
	createNewDayNightCycle()
	
	Serialize.saveGame()
	

func createNewPlayer():
	var playerScene = load("res://scene/entities/player/Player.tscn")
	var player = playerScene.instance()
	player.addCamera()
	add_child(player)
	player.init()
	
func createNewDayNightCycle():
	var dayNightCycleScene = load("res://scene/hud/dayNightCycle/DayNightCycle.tscn")
	var dayNightCycle = dayNightCycleScene.instance()
	add_child(dayNightCycle)
	dayNightCycle.init()
