class_name BTIsOpponentOnView extends BTTask
## BTIsOpponentOnView — casts vision raycasts during BT tick (not every frame).
## SUCCESS: opponent is visible via vision rays
## FAILURE: opponent not in line of sight

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	var opponent = blackboard.get(BlackboardKeys.OPPONENT)
	
	if not opponent or not is_instance_valid(opponent):
		return Status.FAILURE
	
	# Use enemy's vision system
	if agent.has_method("can_see_target"):
		if agent.can_see_target(opponent):
			# Update last known position
			if opponent is Node2D:
				blackboard[BlackboardKeys.LAST_KNOWN_POS] = opponent.global_position
			return Status.SUCCESS
	
	return Status.FAILURE
