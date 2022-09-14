extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	if owner.name == "Minimap": Globals.currentMap.connect("onReady", self, "init")
	else: loadMap()

func init():
	for node in get_tree().get_nodes_in_group("map"):
		var newNode = node.duplicate()
		newNode.global_position = node.global_position
		add_child(newNode)

func loadMap():
	var xOffset = -Globals.currentMap.blocks.size()/2
	var yOffset = -Globals.currentMap.blocks[0].size()/2
	for x in Globals.currentMap.blocks.size():
		for y in Globals.currentMap.blocks[x].size():
			var map = load("res://scene/maps/maps/"+Globals.currentMap.blocks[x][y]+"/block.tscn").instance()
			map.position = Vector2((y+yOffset)*(Constants.BLOCK_SIZE*2), (x+xOffset)*(Constants.BLOCK_SIZE*2))
			add_child(map)

	for child in get_children():
		var map = Utils.findNodeDescendantsInGroup(child, 'map')
		for node in map:
			var newNode = node.duplicate()
			newNode.position = node.global_position
			add_child(newNode)
		child.queue_free()
	
