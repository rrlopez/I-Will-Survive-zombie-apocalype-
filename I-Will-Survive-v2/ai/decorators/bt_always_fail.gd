class_name BTAlwaysFail extends BTTask
## BTAlwaysFail — always returns FAILURE regardless of child status.
## RUNNING still passes through.

@export var child: BTTask = null

func setup(blackboard: Dictionary, agent: Node) -> void:
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.FAILURE
	
	var status := child.tick(blackboard, agent, delta)
	
	if status == Status.RUNNING:
		return Status.RUNNING
	
	return Status.FAILURE

func reset() -> void:
	if child:
		child.reset()
