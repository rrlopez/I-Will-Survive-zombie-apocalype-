extends Node2D

signal stateReady

export(NodePath) onready var transition  = get_node(transition) as CanvasLayer

var gameStateScene = preload("res://scene/states/gameState/GameState.tscn")

onready var states = {
	"gameState": null,
	"pauseState": preload("res://scene/states/pauseState/pauseState.tscn").instance(),
	"mapState": preload("res://scene/states/mapState/mapState.tscn").instance(),
	"gameOverState": preload("res://scene/states/gameOverState/gameOverState.tscn").instance(),
	"menuState": preload("res://scene/states/menuState/menuState.tscn").instance(),
	"loadingState": preload("res://scene/states/loadingState/loadingState.tscn").instance()
}

onready var currentStates = []

func _ready():
	Globals.stateManager = self
	pushState("menuState")

func popState():
	if currentStates.size() < 2: return 
	transition.animation.play("disolve")
	yield(transition.animation, "animation_finished")
	remove_child(currentStates[0])
	currentStates.pop_front()
	add_child(currentStates[0])
	move_child(currentStates[0], 0)
	emit_signal("stateReady")
	transition.animation.play_backwards("disolve")
	
func pushState(name):
	var state = states[name]
	if currentStates.size()>0: 
		if currentStates[0] == state: return
		var prevState = currentStates[0]
		currentStates.push_front(state)
		transition.animation.play("disolve")
		yield(transition.animation, "animation_finished")
		remove_child(prevState)
		
	else: currentStates.push_front(state)
	add_child(currentStates[0])
	move_child(currentStates[0], 0)
	emit_signal("stateReady")
	transition.animation.play_backwards("disolve")

func addOverlayState(name):
	add_child(states[name])
	move_child(states[name], 0)
	
func removeOverlayState(name):
	if get_child_count() > 1 and get_node(name):
		remove_child(states[name])
	
