class_name BTWait extends BTTask
## BTWait — waits for specified duration before ticking child.
## Fixed: _elapsed starts at 0 and counts UP until reaching wait_time.

@export var wait_time: float = 1.0
@export var child: BTTask = null

var _elapsed: float = 0.0

func setup(blackboard: Dictionary, agent: Node) -> void:
	_elapsed = 0.0
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.FAILURE
	
	# Wait period
	if _elapsed < wait_time:
		_elapsed += delta
		return Status.RUNNING
	
	# Wait complete, tick child
	var status := child.tick(blackboard, agent, delta)
	
	if status != Status.RUNNING:
		reset()
	
	return status

func reset() -> void:
	_elapsed = 0.0
	if child:
		child.reset()
