extends Leaf

class_name attackOpponent

func run(_delta):
	if agent.attackTimer <= 0: 
		agent.attack()
		return success()
	return fail()
