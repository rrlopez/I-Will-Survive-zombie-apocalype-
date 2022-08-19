class_name Attack extends Resource

var agent = null

func init(_agent):
	agent = _agent

func use():
	agent.hitBox.collider.shape.radius = 1
	agent.curAttack = self

func attack():
	agent.body.lowerBodyAnimation.stop()
	agent.path = []
	pass

func isAttacking(delta):
	pass

func landed():
	for opponent in agent.hitBox.opponents:
		opponent.hurt(agent.data.stats.attack_dmg.val)
