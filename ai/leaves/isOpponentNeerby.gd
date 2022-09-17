extends Leaf

class_name isOpponentNeerby

func run(_delta):
	if(agent.opponent.empty()): return fail()
	for enemy in agent.opponent:
		if !weakref(agent.opponent[0]).get_ref():
			agent.opponent.erase(enemy)
	if(agent.global_position.distance_to(agent.opponent[0].global_position)<agent.data.stats.loose_range.val): return success()
	
	agent._on_View_body_exited(null)
	fail()
