class_name BTNavigatePath extends BTTask
## BTNavigatePath — follows the navigation path.
## RUNNING: still navigating
## SUCCESS: arrived at destination
## FAILURE: no path or navigation failed

func tick(_blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Get NavigationAgent2D
	if not agent.has_node("NavigationAgent2D"):
		return Status.FAILURE
	
	var nav_agent := agent.get_node("NavigationAgent2D") as NavigationAgent2D
	if not nav_agent:
		return Status.FAILURE
	
	# Check if navigation is finished
	if nav_agent.is_navigation_finished():
		return Status.SUCCESS
	
	# Check if we have a valid path
	if nav_agent.get_current_navigation_path().is_empty():
		return Status.FAILURE
	
	# Still navigating (movement is handled in enemy._physics_process)
	return Status.RUNNING
