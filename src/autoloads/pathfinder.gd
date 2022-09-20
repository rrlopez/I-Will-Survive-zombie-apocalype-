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
		newData.append([data[0], Globals.curRegion.navigation.get_simple_path(data[1], data[2], true)])
	call_deferred("pathGenerated", newData)

func pathGenerated(agents):
	for data in agents:
		if is_instance_valid (data[0]): data[0].generatePath(data[1])
	pathfinder_thread.wait_to_finish()

func requestPath(agent):
	agents_to_update.append([agent, agent.global_position, agent.getDestination()])
