extends Leaf

class_name isOpponentInRange

func run(_delta):
	#if agent.hitBox.opponents.empty(): return fail()
	
	if(agent.attackRange.is_colliding()): 
		agent.attack()
		return success()
	return fail()
