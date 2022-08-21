extends Node2D

onready var states = {
	"gameState": preload("res://scene/states/GameState.tscn").instance(),
	"pauseState": preload("res://scene/states/pauseState/pauseState.tscn").instance(),
	"mapState": preload("res://scene/states/mapState/mapState.tscn").instance(),
	"gameOverState": preload("res://scene/states/gameOverState/gameOverState.tscn").instance()
}

onready var currentStates = []

func _ready():
	Globals.stateManager = self
	pushState("gameState")

func popState():
	if currentStates.size() < 2: return 
	remove_child(currentStates[0])
	currentStates.pop_front()
	add_child(currentStates[0])
	
func pushState(name):
	var state = states[name]
	if currentStates.size()>0: 
		if currentStates[0] == state: return
		remove_child(currentStates[0])
	currentStates.push_front(state)
	add_child(currentStates[0])
