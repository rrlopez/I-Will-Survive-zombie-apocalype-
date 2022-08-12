extends Node

export(NodePath) onready var root  = get_node(root) as Task
export(NodePath) onready var agent  = get_node(agent) as KinematicBody2D

func _ready():
	root.start(agent)


func _process(_delta):
	root.run()
