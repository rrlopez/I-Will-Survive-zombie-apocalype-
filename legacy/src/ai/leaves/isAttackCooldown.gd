extends Leaf

class_name isAttackCooldown

func run(delta):
	if agent.attackTimer <= 0: return success()
	agent.attackTimer-=delta
	return fail()
