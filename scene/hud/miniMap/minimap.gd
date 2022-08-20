extends ColorRect

export(NodePath) onready var map = get_node(map) as Area2D
export(NodePath) onready var camera = get_node(camera) as Camera2D
export(NodePath) onready var playerMark = get_node(playerMark) as Sprite



func _process(delta):
		
	playerMark.global_position = Vector2(Globals.player.global_position)
	playerMark.rotation_degrees = Globals.player.rotation_degrees
	pass
