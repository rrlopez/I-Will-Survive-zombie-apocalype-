extends Leaf

class_name isPathGenerated

func run(_delta):
	if agent.isPathGenerated:
		agent.body.lowerBodyAnimation.play("run_stright")
		return success()
	return fail()
