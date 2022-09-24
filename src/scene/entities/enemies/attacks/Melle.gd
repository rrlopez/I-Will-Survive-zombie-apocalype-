extends Attack


func _init(_agent, _data):
	.init(_agent, _data)

func use():
	.use()
	agent.hitBoxCollider.scale = Vector2(agent.data.stats.attack_range.val, agent.data.stats.size.val/4)
	agent.hitBoxCollider.position = Vector2(agent.data.stats.attack_range.val, 0)
	agent.attackRange.cast_to = Vector2(agent.data.stats.attack_range.val, 0)

func attack():
	.attack()
	agent.body.upperBodyAnimation.play("attack")

func isAttacking(_delta):
	if agent.body.upperBodyAnimation.is_playing(): return true
	return false

