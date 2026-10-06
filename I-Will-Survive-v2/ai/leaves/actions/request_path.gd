class_name BTRequestPath extends BTTask
## BTRequestPath — requests a navigation path to the destination.
## Sets NavigationAgent2D target_position from blackboard DESTINATION.

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	var destination: Vector2 = blackboard.get(BlackboardKeys.DESTINATION, Vector2.ZERO)
	
	if destination == Vector2.ZERO:
		return Status.FAILURE
	
	# Get NavigationAgent2D
	if not agent.has_node("NavigationAgent2D"):
		return Status.FAILURE
	
	var nav_agent := agent.get_node("NavigationAgent2D") as NavigationAgent2D
	if not nav_agent:
		return Status.FAILURE
	
	# Request path
	nav_agent.target_position = destination
	blackboard[BlackboardKeys.PATH_READY] = true
	
	return Status.SUCCESS
