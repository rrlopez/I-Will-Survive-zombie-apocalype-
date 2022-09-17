extends Node2D

signal rerender
var map = null

func _ready():
	yield(get_tree(), "idle_frame")
	map = get_child(0)
	if owner.name == "Minimap": 
		connect("rerender", self, "init")
		Globals.currentMap.connect("onReady", self, "init", [], CONNECT_ONESHOT)
	else: loadMap()

func init():
	for child in map.get_children(): child.queue_free()
	for node in get_tree().get_nodes_in_group("map"):
		var newNode = node.duplicate()
		newNode.global_position = node.global_position
		newNode.rotation = node.global_rotation
		map.add_child(newNode)

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
			newNode.rotation = node.global_rotation
			add_child(newNode)
		child.queue_free()
	
