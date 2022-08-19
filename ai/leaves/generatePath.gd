extends Leaf

class_name generatePath

func run(_delta):
	if agent.opponent.empty() or agent.opponent[0] == null: return fail()
	agent.path = Globals.currentNavigation.get_simple_path(agent.global_position, agent.opponent[0].global_position, true)
	agent.path.pop_front()
	agent.body.lowerBodyAnimation.play("run_stright")
	return success()
