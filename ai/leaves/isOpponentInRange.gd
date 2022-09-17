extends Leaf

class_name isOpponentInRange

func run(_delta):
	if(agent.attackRange.is_colliding()): 
		agent.body.lowerBodyAnimation.stop()
		return success()
	return fail()
