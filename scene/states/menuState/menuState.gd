extends Node2D

export(NodePath) onready var continueBtn  = get_node(continueBtn) as MarginContainer

func _ready():
	continueBtn.visible = Serialize.hasLoadData()


func _on_ContinueBtn_button_up():
	Globals.stateManager.pushState("gameState")
	Globals.stateManager.currentStates[0].continueGame()


func _on_NewGameBtn_button_up():
	Globals.stateManager.pushState("gameState")
	Globals.stateManager.currentStates[0].newGame()


func _on_ExitBtn_button_up():
	pass # Replace with function body.
