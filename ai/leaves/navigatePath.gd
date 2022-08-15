extends Leaf

class_name navigatePath

func run(delta):
	if agent.path.size() > 0:
		agent.velocity = agent.global_position.direction_to(agent.path[0]).normalized()*3
		
		agent.look_at(agent.path[0])
		agent.velocity = agent.move_and_slide(agent.velocity*agent.data.stats.move_speed*Constants.MOVE_SPEED_MULTIPLYER*delta)
		
		if agent.global_position.distance_to(agent.path[0])<10:
			agent.path.pop_front()
		success()
	else: 
		agent.velocity = Vector2.ZERO
		fail()
