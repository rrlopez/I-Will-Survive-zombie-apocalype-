extends Leaf

class_name attackOpponent

func run(_delta):
	if !agent.isAttacking(_delta): success()
