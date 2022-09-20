extends Leaf

class_name isPathGenerated

func run(_delta):
	if agent.isPathGenerated:
		return success()
	return fail()
