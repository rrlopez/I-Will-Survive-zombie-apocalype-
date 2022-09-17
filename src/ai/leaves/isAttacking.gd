extends Leaf

class_name isAttacking

func run(_delta):
	if agent.isAttacking(_delta): return running()
	return success()
