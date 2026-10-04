class_name Attack extends Resource

var agent = null
var data = null

func init(_agent, _data):
	agent = _agent
	data = _data

func use():
	agent.hitBoxCollider.shape.radius = 1
	agent.curAttack = self

func attack():
	agent.body.lowerBodyAnimation.stop()
	agent.path = []
	pass

func isAttacking(_delta):
	pass

func landed():
	for opponent in agent.enemiesAbleToAttack:
		for statusEffect in data.statusEffects:
			Factory.statusEffects.create(statusEffect.duplicate(true), opponent, agent)
		opponent.hurt(agent.data.stats.attack_dmg.val)

func serialize():
	return data
	

func deserialize(savedData):
	data = savedData

	
