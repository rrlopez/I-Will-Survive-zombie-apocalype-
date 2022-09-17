extends Leaf

class_name chooseOpponent

func run(_delta):
	agent.attackTimer = agent.curAttack.data.cooldown
	agent.chooseAttack()
	success()
