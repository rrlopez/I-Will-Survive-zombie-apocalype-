class_name BTWanderToDestination extends BTTask
## BTWanderToDestination — checks if wander destination is reached.
## Does NOT set velocity - the enemy's movement system handles that.

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	if not agent is CharacterBody2D:
		return Status.FAILURE
	
	var destination = blackboard.get(BlackboardKeys.DESTINATION, null)
	if not destination or not destination is Vector2:
		return Status.FAILURE
	
	var distance: float = agent.global_position.distance_to(destination)
	
	# Reached destination
	if distance < 30.0:
		return Status.SUCCESS
	
	# Still moving toward destination (enemy movement system handles it)
	return Status.RUNNING
