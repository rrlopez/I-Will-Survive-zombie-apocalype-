extends Leaf

class_name isChasing

func run(_delta):
	if(agent.data.states.isChasing): success()
	else:
		if(!agent.data.states.isIdle): agent._on_View_body_exited(null)
		fail()
