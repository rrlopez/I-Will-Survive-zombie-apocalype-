extends Leaf

class_name generatePath

func run(_delta):
	var destination = agent.getDestination()
	if destination:
		agent.path = Navigation2DServer.map_get_path(agent.navAgent.get_navigation_map(), agent.global_position, destination, true)
		agent.path.pop_front()
		return success()
	return fail()
