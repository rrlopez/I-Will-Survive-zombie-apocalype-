extends Leaf

class_name isVisible

func run(_delta):
	if(agent.visible): success()
	else: fail()
