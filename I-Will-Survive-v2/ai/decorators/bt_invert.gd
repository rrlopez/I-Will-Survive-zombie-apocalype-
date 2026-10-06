class_name BTInvert extends BTTask
## BTInvert — inverts child's success/failure status.
## SUCCESS → FAILURE, FAILURE → SUCCESS, RUNNING → RUNNING

@export var child: BTTask = null

func setup(blackboard: Dictionary, agent: Node) -> void:
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.FAILURE
	
	var status := child.tick(blackboard, agent, delta)
	
	match status:
		Status.SUCCESS:
			return Status.FAILURE
		Status.FAILURE:
			return Status.SUCCESS
		_:
			return Status.RUNNING

func reset() -> void:
	if child:
		child.reset()
