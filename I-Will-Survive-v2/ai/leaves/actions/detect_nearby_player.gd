class_name BTDetectNearbyPlayer extends BTTask
## BTDetectNearbyPlayer — detects player within range or vision cone.
## Only sets player as opponent if they're close enough or visible.

@export var detection_range: float = 150.0  # Short proximity range (aggro circle)

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Get player
	var player: Node = null
	if Globals.player and is_instance_valid(Globals.player):
		player = Globals.player
	
	if not player:
		return Status.FAILURE
	
	# Check if player is in proximity range (360 degrees, short range)
	var distance: float = agent.global_position.distance_to(player.global_position)
	var in_proximity: bool = distance <= detection_range
	
	# Check vision cone (forward-facing, longer range)
	var in_vision: bool = false
	if agent.has_method("can_see_target"):
		in_vision = agent.can_see_target(player)
	
	# Debug: print occasionally when close
	if distance < 200.0 and randf() < 0.05:
		print("[DETECT] dist=%.0f prox=%s vision=%s range=%.0f" % [distance, in_proximity, in_vision, detection_range])
	
	# Detect if EITHER in proximity OR in vision
	if in_proximity or in_vision:
		# Set opponent in blackboard AND on agent
		blackboard[BlackboardKeys.OPPONENT] = player
		if agent.has_method("set_opponent"):
			agent.set_opponent(player)
		return Status.SUCCESS
	
	return Status.FAILURE
