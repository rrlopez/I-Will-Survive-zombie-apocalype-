extends Leaf

class_name isOpponentInRange

func run():
	if(agent.opponent and agent.global_position.distance_to(agent.opponent.global_position)<agent.data.stats.attack_range+30):
		agent.data.states.isAttacking = true
		agent.lowerBodyAnimation.stop()
		success()
	else: 
		agent.data.states.isAttacking = false
		fail()
