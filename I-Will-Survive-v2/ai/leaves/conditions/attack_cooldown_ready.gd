class_name BTAttackCooldownReady extends BTTask
## BTAttackCooldownReady — checks and decrements attack cooldown timer.
## SUCCESS: cooldown is ready (timer <= 0)
## FAILURE: still on cooldown

func tick(blackboard: Dictionary, _agent: Node, delta: float) -> Status:
	var timer: float = blackboard.get(BlackboardKeys.ATTACK_TIMER, 0.0)
	
	# Decrement timer
	if timer > 0.0:
		timer -= delta
		blackboard[BlackboardKeys.ATTACK_TIMER] = timer
		return Status.FAILURE
	
	# Cooldown ready
	return Status.SUCCESS
