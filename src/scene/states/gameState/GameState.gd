extends Node2D

var timer = 10
var curTimer = timer

func _ready():
	Globals.stateManager.addOverlayState("loadingState")
	Serialize.connect("dataSaved", self, "resetTimer")

func _process(delta):
	if curTimer < 0:
		Serialize.saveGame()
	else: curTimer-=delta


func continueGame():
	Serialize.loadGame()
	

func newGame():
	createNewHotbar()
	createNewPlayer()
	createNewDayNightCycle()
	Serialize.saveGame()

func createNewHotbar():
	var hotbarScene = load("res://scene/hud/hotbar/hotbar.tscn")
	var hotbar = hotbarScene.instance()
	hotbar.init()

func createNewPlayer():
	var playerScene = load("res://scene/entities/player/Player.tscn")
	var player = playerScene.instance()
	player.position = Vector2(600, 1700)
	add_child(player)
	player.init()
	
func createNewDayNightCycle():
	var dayNightCycleScene = load("res://scene/hud/dayNightCycle/DayNightCycle.tscn")
	var dayNightCycle = dayNightCycleScene.instance()
	add_child(dayNightCycle)
	dayNightCycle.init()

func resetTimer():
	curTimer = timer
