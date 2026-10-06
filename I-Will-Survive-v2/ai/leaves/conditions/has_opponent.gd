class_name BTHasOpponent extends BTTask
## BTHasOpponent — checks if blackboard has a valid opponent.
## SUCCESS: opponent exists and is valid
## FAILURE: no opponent or invalid

func tick(blackboard: Dictionary, _agent: Node, _delta: float) -> Status:
	var opponent = blackboard.get(BlackboardKeys.OPPONENT)
	
	if opponent and is_instance_valid(opponent):
		return Status.SUCCESS
	
	return Status.FAILURE
