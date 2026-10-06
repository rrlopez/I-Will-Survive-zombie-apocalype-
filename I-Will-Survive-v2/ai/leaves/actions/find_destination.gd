class_name BTFindDestination extends BTTask
## BTFindDestination — picks a random wander destination near the agent.
## Idle duration is driven by the agent's idle_time stat (randomised at spawn
## from a min/max range defined in enemies.json).
##
## Return contract:
##   SUCCESS  → destination is valid, enemy should move toward it
##   RUNNING  → enemy is idling between wander legs (standing still)
##   FAILURE  → agent is not a Node2D (hard error)

@export var wander_radius: float = 300.0
@export var arrival_threshold: float = 30.0
## Fallback idle duration when the agent has no idle_time stat.
@export var idle_fallback: float = 3.0

func tick(blackboard: Dictionary, agent: Node, delta: float) -> Status:
	if not agent is Node2D:
		return Status.FAILURE

	var agent2d := agent as Node2D

	# --- Idle cooldown ---
	var timer: float = blackboard.get(BlackboardKeys.WANDER_TIMER, 0.0)
	if timer > 0.0:
		blackboard[BlackboardKeys.WANDER_TIMER] = maxf(0.0, timer - delta)
		return Status.RUNNING

	# --- Still travelling? ---
	var current_dest = blackboard.get(BlackboardKeys.DESTINATION, null)
	if current_dest is Vector2:
		var dist: float = agent2d.global_position.distance_to(current_dest)
		if dist > arrival_threshold:
			return Status.SUCCESS  # Keep moving

		# Arrived — start idle pause
		blackboard[BlackboardKeys.DESTINATION] = null
		blackboard[BlackboardKeys.WANDER_TIMER] = _get_idle_duration(agent)
		return Status.RUNNING

	# --- No destination (spawn or finished idling) — pick one now ---
	_pick_new_destination(blackboard, agent2d)
	return Status.SUCCESS

func _get_idle_duration(agent: Node) -> float:
	if "stats" in agent:
		var stats = agent.get("stats")
		if stats and stats.has_method("has_stat") and stats.has_stat(&"idle_time"):
			var s: Stat = stats.get_stat(&"idle_time")
			if s:
				return s.value
	return idle_fallback

func _pick_new_destination(blackboard: Dictionary, agent: Node2D) -> void:
	var angle    := randf() * TAU
	var distance := randf_range(wander_radius * 0.3, wander_radius)
	blackboard[BlackboardKeys.DESTINATION] = agent.global_position + Vector2(cos(angle), sin(angle)) * distance
