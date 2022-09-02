extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	var xOffset = -Globals.currentMap.blocks.size()/2
	var yOffset = -Globals.currentMap.blocks[0].size()/2
	for x in Globals.currentMap.blocks.size():
		for y in Globals.currentMap.blocks[x].size():
			var map = load("res://scene/maps/maps/"+Globals.currentMap.blocks[x][y]+"/map.tscn").instance()
			map.position = Vector2((x+xOffset)*(Constants.BLOCK_SIZE*2), (y+yOffset)*(Constants.BLOCK_SIZE*2))
			add_child(map)
