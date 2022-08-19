extends Leaf

class_name isOpponentInRange

func run(_delta):
	if agent.hitBox.opponents.empty(): return fail()
	agent.attack()
	return success()
