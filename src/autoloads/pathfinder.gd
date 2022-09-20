extends Node

var maxTimer = 0.5
var timer = 0
var pathfinder_thread
var agents_to_update = []

func _ready():
	pathfinder_thread = Thread.new()
	self.set_physics_process(false)
	timer = maxTimer

func _physics_process(_delta):
	timer+=_delta
	if timer>maxTimer:
		if pathfinder_thread.is_active(): return
		pathfinder_thread.start(self, "_async_pathfinder", agents_to_update.duplicate(), 0)
		agents_to_update = []
		timer=0

func _async_pathfinder(agents):
	for data in agents: 
		var path = Globals.curRegion.navigation.get_simple_path(data[1], data[2], true)
		data[0].call_deferred("generatePath", path)
	pathfinder_thread.call_deferred("wait_to_finish")

func requestPath(agent):
	agents_to_update.append([agent, agent.global_position, agent.getDestination()])
