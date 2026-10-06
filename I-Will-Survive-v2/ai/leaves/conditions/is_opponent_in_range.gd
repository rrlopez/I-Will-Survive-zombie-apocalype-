class_name BTIsOpponentInRange extends BTTask
## BTIsOpponentInRange — checks if opponent is within attack range.
## SUCCESS: opponent is close enough to attack
## FAILURE: opponent is too far

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	var opponent = blackboard.get(BlackboardKeys.OPPONENT)
	
	if not opponent or not is_instance_valid(opponent):
		return Status.FAILURE
	
	# Get attack range from stats
	if not agent.has_node("StatsComponent"):
		return Status.FAILURE
	
	var stats = agent.get_node("StatsComponent")
	if not stats or not stats.has_stat("attack_range"):
		return Status.FAILURE
	
	var attack_range: float = stats.attack_range.value if stats.attack_range else 30.0
	
	# Check distance
	if opponent is Node2D and agent is Node2D:
		var distance: float = agent.global_position.distance_to(opponent.global_position)
		if distance <= attack_range:
			return Status.SUCCESS
	
	return Status.FAILURE
