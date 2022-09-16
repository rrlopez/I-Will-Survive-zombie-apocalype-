extends Leaf

class_name isAttackCooldown

var timer = 0

func run(delta):
	if timer >= agent.curAttack.data.cooldown:
		timer = 0
		return fail()
	timer+=delta
	return success()
