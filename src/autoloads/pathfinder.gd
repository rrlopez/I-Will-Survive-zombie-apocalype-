extends Node

var maxTimer = 0.5
var timer = 0
var pathfinder_thread = Thread.new()
var agents_to_update = []

func _ready():
	self.set_physics_process(false)
	timer = maxTimer

func _physics_process(_delta):
	if not pathfinder_thread.is_active() and timer>maxTimer:
		pathfinder_thread.start(self, "_async_pathfinder", agents_to_update.duplicate(), 0)
		agents_to_update = []
		timer=0
	timer+=_delta

func _async_pathfinder(agents):
	for agent in agents: agent.call_deferred("generatePath")
	pathfinder_thread.call_deferred("wait_to_finish")

func requestPath(agent):
	agents_to_update.append(agent)
