extends Leaf

class_name requestPath

func run(_delta):
	if agent.getDestination():
		agent.isPathGenerated = false
		Pathfinder.requestPath(agent)
		return success()
	return fail()
