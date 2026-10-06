class_name BTValidateOpponent extends BTTask
## BTValidateOpponent — validates opponent reference and clears if invalid.
## SUCCESS: opponent is valid
## FAILURE: opponent was invalid (and has been cleared)

func tick(blackboard: Dictionary, _agent: Node, _delta: float) -> Status:
	var opponent = blackboard.get(BlackboardKeys.OPPONENT)
	
	if not opponent or not is_instance_valid(opponent):
		# Clear invalid opponent
		blackboard[BlackboardKeys.OPPONENT] = null
		return Status.FAILURE
	
	# Check if opponent is freed or queued for deletion
	if opponent is Node:
		if opponent.is_queued_for_deletion():
			blackboard[BlackboardKeys.OPPONENT] = null
			return Status.FAILURE
	
	return Status.SUCCESS
