extends Node2D

func continueGame():
	Serialize.loadGame()
	Globals.player.addCamera()
	pass
	

func newGame():
	var playerScene = load("res://scene/entities/player/Player.tscn")
	var player = playerScene.instance()
	player.addCamera()
	add_child(player)
	player.init()
	Serialize.saveGame()
	
	
