extends Attack

var force

func _init(_agent, _data):
	.init(_agent, _data)

func use():
	.use()
	agent.attackRange.cast_to = Vector2(agent.data.stats.vision.val.height/2, 0)
	agent.set_collision_layer_bit(1, true)
	agent.set_collision_mask_bit(0, true)
	agent.set_collision_mask_bit(1, true)

func attack():
	.attack()
	agent.hitBox.collider.scale = Vector2(1, 1)
	agent.hitBox.collider.shape.radius = agent.data.stats.size.val/2
	agent.hitBox.collider.position = Vector2(0, 0)
	force = ApplyForce.new()
	force.init({"force": agent.data.stats.vision.val.height/7,  "friction": 0.9 })
	force.add(agent.opponent[0], agent)
	agent.set_collision_layer_bit(1, false)
	agent.set_collision_mask_bit(0, false)
	agent.set_collision_mask_bit(1, false)

func isAttacking(delta):
	if !force: return false
	if force.run(agent, delta):
		use()
		return false
	landed()
	agent.hitBox.opponents = []
	return true


