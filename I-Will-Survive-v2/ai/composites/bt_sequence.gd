class_name BTSequence extends BTTask
## BTSequence — reactive sequence.
## Re-evaluates children from the TOP every tick.
## This means condition checks (has_opponent, is_in_range) are re-tested
## every tick, so the sequence aborts immediately when conditions fail.
##
## SUCCESS: all children succeed
## FAILURE: any child fails
## RUNNING: all children so far succeeded, last returned RUNNING

@export var children: Array[BTTask] = []

func setup(blackboard: Dictionary, agent: Node) -> void:
	for child in children:
		if child:
			child.setup(blackboard, agent)

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if children.is_empty():
		return Status.SUCCESS
	
	# Always iterate from child 0 — reactive semantics.
	# Condition children (has_opponent, is_in_range) re-check every tick.
	for child in children:
		if not child:
			continue
		
		var status := child.tick(blackboard, agent, delta)
		
		match status:
			Status.FAILURE:
				return Status.FAILURE
			Status.RUNNING:
				return Status.RUNNING
			Status.SUCCESS:
				pass  # Continue to next child
	
	# All children succeeded
	return Status.SUCCESS

func reset() -> void:
	for child in children:
		if child:
			child.reset()
