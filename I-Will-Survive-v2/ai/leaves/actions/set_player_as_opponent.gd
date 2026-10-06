class_name BTSetPlayerAsOpponent extends BTTask
## BTSetPlayerAsOpponent — sets the player as the opponent target.
## Uses Globals.player or searches for player in tree.

func tick(blackboard: Dictionary, agent: Node, _delta: float) -> Status:
	# Try to get player from Globals
	var player: Node = null
	if Globals.player and is_instance_valid(Globals.player):
		player = Globals.player
	
	# Fallback: search for player in tree
	if not player or not is_instance_valid(player):
		var players := agent.get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
	
	if not player or not is_instance_valid(player):
		return Status.FAILURE
	
	# Set opponent in blackboard
	blackboard[BlackboardKeys.OPPONENT] = player
	
	# Also call agent's set_opponent method if available
	if agent.has_method("set_opponent"):
		agent.set_opponent(player)
	
	return Status.SUCCESS
