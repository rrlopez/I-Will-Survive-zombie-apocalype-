extends Attack


func _init(_agent):
	.init(_agent)

func use():
	.use()
	agent.hitBox.collider.scale = Vector2(agent.data.stats.attack_range.val, agent.data.stats.size.val/4)
	agent.hitBox.collider.position = Vector2(agent.data.stats.attack_range.val, 0)

func attack():
	.attack()
	agent.body.upperBodyAnimation.play("attack")

func isAttacking(_delta):
	if agent.body.upperBodyAnimation.is_playing(): return true
	return false

