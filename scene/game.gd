extends Node2D


export(NodePath) onready var fps  = get_node(fps) as Label

func _process(delta):
	fps.text = "FPS " + String(Engine.get_frames_per_second())
