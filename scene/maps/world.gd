extends Area2D

onready var regionScene = preload("res://scene/maps/regionSensor/regionSensor.tscn")

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var navigation  = get_node(navigation) as Navigation2D
export(NodePath) onready var regions  = get_node(regions) as Node2D


var blocks = [
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
	["block3","block3","block3","block3","block3","block3","block3","block3","block3"],
]

func _ready():
	collider.shape.extents = Vector2(blocks.size()*Constants.BLOCK_SIZE, blocks[0].size()*Constants.BLOCK_SIZE)
	collider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	
	var xOffset = -blocks.size()/2
	var yOffset = -blocks[0].size()/2
	for x in blocks.size():
		for y in blocks[x].size():
			var region = regionScene.instance()
			region.position = Vector2((x+xOffset)*(Constants.BLOCK_SIZE*2), (y+yOffset)*(Constants.BLOCK_SIZE*2))
			region.blockName = blocks[x][y]
			regions.add_child(region)
