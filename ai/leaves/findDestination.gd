extends Leaf

class_name findDestination

var wanderTimer = 0
var maxWanderTimer = 12
var wanderDistance = 200

func start(agent):
	.start(agent)
	resetTimer()

func run(_delta):
	if wanderTimer>0:
		wanderTimer-=_delta
		return running()
		
	if agent.opponent.empty():
		resetTimer()
		Constants.rand.randomize()
		agent.destination = agent.global_position + (Vector2.ONE*wanderDistance).rotated(Constants.rand.randi_range(0, 360))
		return success()
	return fail()


func resetTimer():
	Constants.rand.randomize()
	wanderTimer = Constants.rand.randi_range(10, maxWanderTimer)
