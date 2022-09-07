extends Area2D

export(NodePath) onready var collider = get_node(collider) as CollisionShape2D
export(NodePath) onready var areaCollider = get_node(areaCollider) as CollisionShape2D

var thread_timer = Timer.new()
var blockName = "block3"
var block
var thread


func _ready():
	collider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	areaCollider.position = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	areaCollider.shape.extents = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
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
		block = load("res://scene/maps/maps/"+blockName+"/block.tscn").instance()
		self.call_deferred("add_child", block)
		Serialize.call_deferred("loadRegion", name)
		Globals.currentMap.navigation.generateNavigationPolygon(block)
	else:
		self.call_deferred("add_child", block)
	
	thread_timer.call_deferred("start")
	collider.shape.radius = Constants.BLOCK_SIZE

func leaved(_userdata):
	self.call_deferred("remove_child", block)
	thread_timer.call_deferred("start")
	collider.shape.radius = 50
	
func loadingDone():
	thread.wait_to_finish()
	thread = null

func _on_area_body_entered(body):
	Globals.curRegion = self
