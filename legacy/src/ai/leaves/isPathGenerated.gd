extends Leaf

class_name isPathGenerated

var maxWaitTime = 1
var timer = 0

func run(_delta):
	if agent.isPathGenerated or timer>maxWaitTime:
		timer = 0
		return success()
	timer+=_delta
	return fail()
