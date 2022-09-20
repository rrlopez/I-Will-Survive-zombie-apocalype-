extends Leaf

class_name navigatePath

func run(_delta):
	if agent.body.lowerBodyAnimation.is_playing() and agent.path.size()>0: return success()
	agent.body.lowerBodyAnimation.stop()
	return fail()
