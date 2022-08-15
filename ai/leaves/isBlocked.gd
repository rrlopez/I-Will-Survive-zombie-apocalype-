extends Leaf

class_name isBlocked

var last_position = Vector2.ZERO
var minBlockTime = 0.5
var blockedTime = 0

func run(delta):
	if agent.global_position.distance_to(last_position)<10:
		blockedTime+=delta
		if blockedTime>minBlockTime: 
			agent.opponent.push_front(agent.blocker)
			last_position = Vector2.ZERO
			blockedTime = 0
			return success()
	last_position = agent.global_position
	return fail()
	
	
func start(agent):
	last_position = Vector2.ZERO
	blockedTime = 0
	.start(agent)


func cancel():
	last_position = Vector2.ZERO
	blockedTime = 0
	.cancel()
