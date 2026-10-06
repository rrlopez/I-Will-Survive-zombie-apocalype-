class_name BTChooseAttack extends BTTask
## BTChooseAttack — selects an attack and sets cooldown timer.
## Uses enemy's default attack from meta or creates a new melee attack.

@export var cooldown: float = 1.0  # Default attack cooldown

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Get attack from agent meta (set by factory)
	var attack = agent.get_meta("default_attack", null)
	
	# Fallback: create a basic melee attack
	if not attack:
		attack = MeleeAttack.new()
	
	# Prepare the attack
	if attack.has_method("prepare") and agent.has_method("execute_attack"):
		attack.prepare(agent)
		agent.execute_attack(attack)
	
	# Set attack cooldown in blackboard
	blackboard[BlackboardKeys.ATTACK_TIMER] = cooldown
	blackboard[BlackboardKeys.IS_ATTACKING] = true
	
	return Status.SUCCESS
