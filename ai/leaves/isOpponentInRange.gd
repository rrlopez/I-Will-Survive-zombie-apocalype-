extends Leaf

class_name isOpponentInRange

func run(_delta):
	if(agent.opponent and agent.global_position.distance_to(agent.opponent.global_position)<agent.data.stats.attack_range+agent.data.stats.size/2):
		agent.lowerBodyAnimation.stop()
		agent.path = []
		return success()
	return fail()
