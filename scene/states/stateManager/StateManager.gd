extends Node2D

onready var currentState = null

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = preload("res://scene/states/GameState.tscn")
	add_child(currentState.instance())
	pass # Replace with function body.
