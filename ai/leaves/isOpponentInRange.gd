extends Leaf

class_name isOpponentInRange

func run(_delta):
	if(agent.opponent.empty() or !agent.opponent[0]): return fail()
	if(agent.global_position.distance_to(agent.opponent[0].global_position)<agent.data.stats.attack_range.val+agent.data.stats.size.val/2):
		agent.lowerBodyAnimation.stop()
		agent.path = []
		return success()
	return fail()
