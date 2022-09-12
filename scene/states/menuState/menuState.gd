extends Node2D

export(NodePath) onready var continueBtn  = get_node(continueBtn) as MarginContainer

func _ready():
	continueBtn.visible = Serialize.hasLoadData()


func _on_ContinueBtn_button_up():
	Globals.stateManager.states.gameState = Globals.stateManager.gameStateScene.instance()
	Globals.stateManager.pushState("gameState")
	Globals.stateManager.connect("stateReady", Globals.stateManager.currentStates[0], "continueGame", [], CONNECT_ONESHOT)


func _on_NewGameBtn_button_up():
	Globals.stateManager.states.gameState = Globals.stateManager.gameStateScene.instance()
	Globals.stateManager.pushState("gameState")
	Globals.stateManager.connect("stateReady", Globals.stateManager.currentStates[0], "newGame", [], CONNECT_ONESHOT)


func _on_ExitBtn_button_up():
	pass # Replace with function body.
