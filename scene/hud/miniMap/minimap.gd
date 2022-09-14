extends ColorRect


export(NodePath) onready var playerMark = get_node(playerMark) as Sprite
export(NodePath) onready var blocks = get_node(blocks) as Node2D


func _process(_delta):
	playerMark.global_position = Vector2(Globals.player.global_position)
	playerMark.rotation_degrees = Globals.player.rotation_degrees
	pass
