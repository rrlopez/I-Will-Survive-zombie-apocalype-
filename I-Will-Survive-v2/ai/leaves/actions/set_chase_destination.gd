class_name BTSetChaseDestination extends BTTask
## BTSetChaseDestination — sets destination to opponent's position.
## Used for chase behavior.

func tick(blackboard: Dictionary, _agent: Node, _delta: float) -> Status:
	var opponent = blackboard.get(BlackboardKeys.OPPONENT)
	
	if not opponent or not is_instance_valid(opponent):
		return Status.FAILURE
	
	if not opponent is Node2D:
		return Status.FAILURE
	
	# Set destination to opponent's current position
	blackboard[BlackboardKeys.DESTINATION] = opponent.global_position
	
	return Status.SUCCESS
