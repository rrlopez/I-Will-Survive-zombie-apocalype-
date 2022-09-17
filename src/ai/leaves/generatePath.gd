extends Leaf

class_name generatePath

func run(_delta):
	var destination = agent.getDestination()
	if destination:
		agent.path = Globals.curRegion.navigation.get_simple_path(agent.global_position, destination, true)
		agent.path.pop_front()
		agent.body.lowerBodyAnimation.play("run_stright")
		return success()
	return fail()
