extends Node2D

var thread_timer = Timer.new()
var blockName = "block3"
var block
var thread

func _ready():
	$LeaveSensor/Collider.shape.radius = Constants.BLOCK_SIZE
	thread_timer.wait_time = 0.4
	thread_timer.one_shot = true
	add_child(thread_timer)

	
func _on_EnterSensor_area_entered(_area):
	if thread: return
	Globals.loadingBlocksCount+=1
	thread = Thread.new()
	thread.start(self, "entered", "loading")


func _on_LeaveSensor_area_exited(_area):
	if thread: return
	thread = Thread.new()
	thread.start(self, "leaved", "loading")


func entered(_userdata):
	if !block: 
		block = load("res://scene/maps/maps/"+blockName+".tscn").instance()
		self.call_deferred("add_child", block)
		Globals.currentMap.navigation.generateNavigationPolygon(block)
		block.position = Vector2(0, 0)
	else:
		self.call_deferred("add_child", block)
	
	thread_timer.call_deferred("start")

func leaved(_userdata):
	remove_child(block)
	
func loadingDone():
	thread.wait_to_finish()
	thread = null
	
