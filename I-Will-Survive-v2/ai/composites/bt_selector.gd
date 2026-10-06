class_name BTSelector extends BTTask
## BTSelector — reactive priority selector.
## Evaluates children from the TOP every tick, returning on first SUCCESS/RUNNING.
## This ensures higher-priority branches (detect, combat) always interrupt
## lower-priority ones (wander) the moment their conditions change.
##
## SUCCESS: first child that succeeds
## FAILURE: all children fail
## RUNNING: a child returned RUNNING (re-evaluated from top next tick)

@export var children: Array[BTTask] = []

func setup(blackboard: Dictionary, agent: Node) -> void:
	for child in children:
		if child:
			child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if children.is_empty():
		return Status.FAILURE
	
	# Always iterate from child 0 — reactive/priority semantics.
	# The moment a higher-priority branch becomes viable it takes over immediately.
	for child in children:
		if not child:
			continue
		
		var status := child.tick(blackboard, agent, delta)
		
		match status:
			Status.RUNNING:
				return Status.RUNNING
			Status.SUCCESS:
				return Status.SUCCESS
			Status.FAILURE:
				pass  # Try next child
	
	# All children failed
	return Status.FAILURE

func reset() -> void:
	for child in children:
		if child:
			child.reset()
