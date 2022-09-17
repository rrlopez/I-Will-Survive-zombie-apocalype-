extends Leaf

class_name navigatePath

func run(_delta):
	if agent.move(_delta): success()
	else: 
		agent.velocity = Vector2.ZERO
		agent.body.lowerBodyAnimation.stop()
		fail()
