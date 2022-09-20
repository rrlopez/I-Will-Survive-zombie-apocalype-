extends Leaf

class_name isBlocked

var last_position = Vector2.ZERO
var minBlockTime = 0.2
var blockedTime = 0

func run(delta):
	if agent.opponent.size()<2 and agent.global_position.distance_to(last_position)<1:
		blockedTime+=delta
		if blockedTime>minBlockTime:
			if(agent.blockerSensor.is_colliding()): 
				agent.opponent.push_front(agent.blockerSensor.get_collider())
				last_position = Vector2.ZERO
				blockedTime = 0
				agent.attackRange.set_collision_mask_bit(2, true)
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
