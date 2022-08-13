extends Leaf

class_name navigatePath

func run(delta):
	if agent.path.size() > 0:
		agent.velocity = agent.global_position.direction_to(agent.path[1])
						
		if agent.global_position == agent.path[0]:
			agent.path.pop_front()
		success()
	else: 
		agent.velocity = Vector2.ZERO
		fail()
