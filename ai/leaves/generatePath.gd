extends Leaf

class_name generatePath

func run(_delta):
	if(agent.opponent):
		agent.path = Globals.currentNavigation.get_simple_path(agent.global_position, agent.opponent.global_position, true)
		return success()
	return fail()
