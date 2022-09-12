extends Leaf

class_name navigatePath

func run(delta):
	if agent.path.size() > 0:
		agent.velocity = agent.global_position.direction_to(agent.path[0]).normalized() * agent.data.stats.move_speed.val*Constants.MOVE_SPEED_MULTIPLYER
		
		agent.look_at(agent.path[0])
		
		if agent.global_position.distance_to(agent.path[0])<10:
			agent.path.pop_front()
		success()
	else: 
		agent.velocity = Vector2.ZERO
		agent.body.lowerBodyAnimation.stop()
		fail()
