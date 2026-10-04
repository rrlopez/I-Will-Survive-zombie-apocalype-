extends Leaf

class_name isOpponentNeerby

func run(_delta):
	var alive = []
	for enemy in agent.opponent:
		if is_instance_valid (enemy): alive.append(enemy)
	agent.opponent = alive
	if(agent.opponent.empty()): return fail()
	if(agent.global_position.distance_to(agent.opponent[0].global_position)<agent.data.stats.loose_range.val): return success()
	
	agent._on_View_body_exited(null)
	return fail()
