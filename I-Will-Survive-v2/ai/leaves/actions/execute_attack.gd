class_name BTExecuteAttack extends BTTask
## BTExecuteAttack — monitors attack execution until complete.
## RUNNING: attack animation/action is ongoing
## SUCCESS: attack completed
## FAILURE: no attack active

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	var is_attacking: bool = blackboard.get(BlackboardKeys.IS_ATTACKING, false)
	
	if not is_attacking:
		return Status.FAILURE
	
	# Check if attack is still active
	if agent.has_method("is_attack_active"):
		if agent.is_attack_active():
			return Status.RUNNING
	
	# Attack finished
	blackboard[BlackboardKeys.IS_ATTACKING] = false
	
	# Resolve attack (apply damage)
	if agent.has_method("resolve_attack"):
		agent.resolve_attack()
	
	return Status.SUCCESS
