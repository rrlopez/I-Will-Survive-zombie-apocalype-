class_name BTLosePlayer extends BTTask
## BTLosePlayer — clears opponent if player is too far away.
## Allows enemies to "give up" the chase and return to wandering.

@export var lose_distance: float = 600.0

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Check if we have an opponent
	var opponent = blackboard.get(BlackboardKeys.OPPONENT, null)
	
	if not opponent or not is_instance_valid(opponent):
		return Status.SUCCESS  # No opponent to lose
	
	# Check distance
	var distance: float = agent.global_position.distance_to(opponent.global_position)
	
	# If player is too far, lose them
	if distance > lose_distance:
		# Clear opponent
		blackboard[BlackboardKeys.OPPONENT] = null
		
		if agent.has_method("set_opponent"):
			agent.set_opponent(null)
		
		print("[LOSE] Enemy lost track of player! (distance: ", distance, ")")
		return Status.SUCCESS
	
	return Status.FAILURE  # Still tracking player
