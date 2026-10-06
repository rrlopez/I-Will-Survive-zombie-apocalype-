class_name BTLimit extends BTTask
## BTLimit — limits child execution to N times, then fails.
## Useful for limiting attempts or tries.

@export var max_count: int = 3
@export var child: BTTask = null

var _count: int = 0

func setup(blackboard: Dictionary, agent: Node) -> void:
	_count = 0
	if child:
		child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not child:
		return Status.FAILURE
	
	if _count >= max_count:
		return Status.FAILURE
	
	var status := child.tick(blackboard, agent, delta)
	
	if status != Status.RUNNING:
		_count += 1
		child.reset()
	
	return status

func reset() -> void:
	_count = 0
	if child:
		child.reset()
