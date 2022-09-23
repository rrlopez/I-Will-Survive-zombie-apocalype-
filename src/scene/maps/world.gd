extends Area2D

signal onReady
signal mapLoaded

onready var regionScene = preload("res://scene/maps/regionSensor/regionSensor.tscn")

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var regions  = get_node(regions) as Node2D

	
var blocks = [
	["top2_left2", "top2_left1", "top2", "top2_right1", "top2_right2"],
	["top1_left2", "top1_left1", "top1", "top1_right1", "top1_right2"],
	["left2", 		"left1", 	"center", 	"right1", 	"right2"],
	["bot1_left2", "bot1_left1", "bot1", "bot1_right1", "bot1_right2"],
	["bot2_left2", "bot2_left1", "bot2", "bot2_right1", "bot2_right2"],
]

var loadedBlocks = []

func _ready():
	collider.shape.extents = Vector2(blocks[0].size()*Constants.BLOCK_SIZE, blocks.size()*Constants.BLOCK_SIZE)
	collider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	var _val = connect("mapLoaded", self, "onMapLoad", [], CONNECT_ONESHOT)
	
	var xOffset = -blocks.size()/2
	var yOffset = -blocks[0].size()/2
	for x in blocks.size():
		for y in blocks[x].size():
			var region = regionScene.instance()
			region.position = Vector2((y+yOffset)*(Constants.BLOCK_SIZE*2), (x+xOffset)*(Constants.BLOCK_SIZE*2))
			region.set_name(blocks[x][y])
			regions.add_child(region)


func onMapLoad():
	Globals.player.addCamera()
	Serialize.loadMap()
	init()
	var _val = connect("mapLoaded", self, "init", [])

func init():
	emit_signal("onReady")
	

	
func mapLoaded(block):
	loadedBlocks.append(block)
	Globals.loadingBlocksCount-=1
	if Globals.loadingBlocksCount>0: return
	
	Globals.stateManager.removeOverlayState("loadingState")
	emit_signal("mapLoaded")
	loadedBlocks = []
	

