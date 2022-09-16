extends Area2D

export(NodePath) onready var collider = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider = get_node(areaCollider) as CollisionShape2D
export(NodePath) onready var navigation = get_node(navigation) as Navigation2D

var thread_timer = Timer.new()
var block
var thread


func _ready():
	collider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	areaCollider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	areaCollider.shape.extents = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)*0.99
		
	thread_timer.connect("timeout", self,"loadingDone")
	thread_timer.wait_time = 0.4
	thread_timer.one_shot = true
	add_child(thread_timer)

	
func _on_regionSensor_area_entered(_area):
	if thread: return
	Globals.loadingBlocksCount+=1
	thread = Thread.new()
	thread.start(self, "entered", "loading")


func _on_regionSensor_area_exited(_area):
	if thread: return
	thread = Thread.new()
	thread.start(self, "leaved", "loading")


func entered(_userdata):
	if !block: 
		block = load("res://scene/maps/maps/"+name+"/block.tscn").instance()
		self.call_deferred("onEntered")
	else:
		self.call_deferred("add_child", block)
	
	thread_timer.call_deferred("start")
	collider.shape.radius = Constants.BLOCK_SIZE

func onEntered():
	self.add_child(block)
	Globals.HUD.minimap.blocks.emit_signal("rerender")
	generateNavigationPolygon()
	Globals.currentMap.mapLoaded(block)

func leaved(_userdata):
	self.call_deferred("onLeaved")


func onLeaved():
	self.remove_child(block)
	thread_timer.start()
	collider.shape.radius = 50
	
func loadingDone():
	thread.wait_to_finish()
	thread = null

func _on_area_body_entered(body):
	Globals.curRegion = self


func _on_regionSensor_child_entered_tree(node):
	if(node.name == "block"):
		Serialize.loadRegion(name)



func generateNavigationPolygon():
	var polygon = navigation.get_child(0).navpoly
	
	var newPolygon = PoolVector2Array()
	newPolygon.append(Vector2(0, Constants.BLOCK_SIZE*2)*0.99)
	newPolygon.append(Vector2(0, 0)*0.99)
	newPolygon.append(Vector2(Constants.BLOCK_SIZE*2, 0)*0.99)
	newPolygon.append(Vector2(Constants.BLOCK_SIZE*2, Constants.BLOCK_SIZE*2)*0.99)
	polygon.add_outline(newPolygon)
	
	var obstacles = Utils.findNodeDescendantsInGroup(block, 'obstacle')
	for obstacle in obstacles:
		newPolygon = PoolVector2Array()
		var polygon_transform = obstacle.get_global_transform()
		var polygon_bp = obstacle.get_polygon()
		for vertex in polygon_bp: newPolygon.append(polygon_transform.xform(vertex)-block.global_position)
		polygon.add_outline(newPolygon)
	
	polygon.make_polygons_from_outlines()
	navigation.get_child(0).navpoly = polygon
	
