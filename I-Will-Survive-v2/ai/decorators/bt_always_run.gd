class_name BTAlwaysRun extends BTTask
## BTAlwaysRun — always returns RUNNING regardless of child status.
## Useful for continuous behaviors that should never complete.

@export var child: BTTask = null

func setup(blackboard: Dictionary, agent: Node) -> void:
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if child:
		child.tick(blackboard, agent, delta)
	
	return Status.RUNNING

func reset() -> void:
	if child:
		child.reset()
