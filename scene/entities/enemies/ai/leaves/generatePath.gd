extends Leaf

class_name generatePath

func run():
	if(agent.opponent):
		agent.path = Globals.currentNavigation.get_simple_path(agent.global_position, agent.opponent.global_position, true)
		success()
	else:
		fail()
