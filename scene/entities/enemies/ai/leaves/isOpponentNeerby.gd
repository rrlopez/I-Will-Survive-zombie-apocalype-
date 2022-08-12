extends Leaf

class_name isOpponentNeerby

func run():
	if(agent.global_position.distance_to(agent.opponent.global_position)<agent.data.stats.loose_range): success()
	else: 
		if(agent.data.states.isChasing): agent._on_View_body_exited(null)
		fail()
