extends Node2D

var timer = 5

func _process(delta):
	if timer < 0:
		timer = 5
		Serialize.saveGame()
	else: timer-=delta


func continueGame():
	Serialize.loadGame()
	Globals.player.addCamera()
	

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
