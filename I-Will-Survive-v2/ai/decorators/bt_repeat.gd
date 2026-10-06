class_name BTRepeat extends BTTask
## BTRepeat — repeats child N times or infinitely.
## Fixed: properly passes delta to child.tick()

@export var times: int = 0  # 0 = infinite
@export var child: BTTask = null

var _count: int = 0

func setup(blackboard: Dictionary, agent: Node) -> void:
	_count = 0
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.FAILURE
	
	# Infinite repeat
	if times == 0:
		var status := child.tick(blackboard, agent, delta)
		if status != Status.RUNNING:
			child.reset()
		return Status.RUNNING
	
	# Limited repeats
	while _count < times:
		var status := child.tick(blackboard, agent, delta)
		
		if status == Status.RUNNING:
			return Status.RUNNING
		
		if status == Status.FAILURE:
			reset()
			return Status.FAILURE
		
		# SUCCESS - increment and continue
		_count += 1
		child.reset()
	
	# Completed all repeats
	reset()
	return Status.SUCCESS

func reset() -> void:
	_count = 0
	if child:
		child.reset()
