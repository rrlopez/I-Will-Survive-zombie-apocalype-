extends Leaf

class_name isOpponentNeerby

func run(_delta):
	if(!agent.opponent.empty()):return success()
	if(agent.global_position.distance_to(agent.opponent[0].global_position)<agent.data.stats.loose_range): return success()
	
	agent._on_View_body_exited(null)
	fail()
