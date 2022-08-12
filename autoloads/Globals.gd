extends Node

var camera = null

var HUD = null

var inventoryManager = null

var player:Player = null
var inventory = null

var mapManager = null
var currentMap = null
var currentNavigation = null


var currentController = null setget setCurrentController
func setCurrentController(controller):
	if(controller):
		for n in HUD.controller.get_children(): HUD.controller.remove_child(n)
		HUD.controller.add_child(controller)
	currentController = controller
