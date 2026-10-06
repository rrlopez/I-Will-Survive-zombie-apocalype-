class_name BTUntilSuccess extends BTTask
## BTUntilSuccess — repeats child until it succeeds.
## Returns RUNNING until child returns SUCCESS.

@export var child: BTTask = null

func setup(blackboard: Dictionary, agent: Node) -> void:
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.SUCCESS
	
	var status := child.tick(blackboard, agent, delta)
	
	match status:
		Status.SUCCESS:
			child.reset()
			return Status.SUCCESS
		Status.FAILURE:
			child.reset()
			return Status.RUNNING
		_:
			return Status.RUNNING

func reset() -> void:
	if child:
		child.reset()
