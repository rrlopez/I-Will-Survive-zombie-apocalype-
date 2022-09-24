extends Node

var maxTimer = 0.5
var timer = 0
var pathfinder_thread
var agents_to_update = []
var maxTimerCall = 10
var timerCounter = 0

func _ready():
	pathfinder_thread = Thread.new()
	self.set_physics_process(false)
	timer = maxTimer
	var _val = connect("tree_exiting", self, "onExit")

func _physics_process(_delta):
	timer+=_delta
	if timer>maxTimer:
		if pathfinder_thread.is_active():
			timerCounter+=1
			if timerCounter>maxTimerCall: pathfinder_thread.wait_to_finish()
			return
			
		pathfinder_thread.start(self, "_async_pathfinder", agents_to_update.duplicate(), 0)
		agents_to_update = []
		timer=0

func _async_pathfinder(agents):
	var newData = []
	for data in agents: 
		if is_instance_valid (data[0]): 
			var path = Navigation2DServer.map_get_path(data[0].navAgent.get_navigation_map(), data[1], data[2], true)
			data[0].generatePath(path)
	call_deferred("pathGenerated", newData)

func pathGenerated(agents):
	pathfinder_thread.wait_to_finish()

func requestPath(agent):
	agents_to_update.append([agent, agent.global_position, agent.getDestination()])

func onExit():
	if pathfinder_thread.is_active(): pathfinder_thread.wait_to_finish()
