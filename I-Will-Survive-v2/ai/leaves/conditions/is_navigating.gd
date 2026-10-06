class_name BTIsNavigating extends BTTask
## BTIsNavigating — checks if navigation is in progress.
## SUCCESS: agent is currently navigating to a destination
## FAILURE: navigation finished or no path

func tick(_blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Check if agent has NavigationAgent2D
	if not agent.has_node("NavigationAgent2D"):
		return Status.FAILURE
	
	var nav_agent := agent.get_node("NavigationAgent2D") as NavigationAgent2D
	if not nav_agent:
		return Status.FAILURE
	
	# Check if navigation is finished
	if nav_agent.is_navigation_finished():
		return Status.FAILURE
	
	# Check if we have a valid path
	if nav_agent.get_current_navigation_path().is_empty():
		return Status.FAILURE
	
	return Status.SUCCESS
