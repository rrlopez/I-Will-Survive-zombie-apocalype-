class_name BTUntilFail extends BTTask
## BTUntilFail — repeats child until it fails.
## Returns RUNNING until child returns FAILURE.

@export var child: BTTask = null

func setup(blackboard: Dictionary, agent: Node) -> void:
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.SUCCESS
	
	var status := child.tick(blackboard, agent, delta)
	
	match status:
		Status.FAILURE:
			child.reset()
			return Status.SUCCESS
		Status.SUCCESS:
			child.reset()
			return Status.RUNNING
		_:
			return Status.RUNNING

func reset() -> void:
	if child:
		child.reset()
