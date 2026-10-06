extends Node
## Debug enemy movement by printing state every second

var check_timer: float = 0.0

func _process(delta: float) -> void:
	check_timer += delta
	if check_timer >= 1.0:
		check_timer = 0.0
		check_movement()

func check_movement() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	var enemy = enemies[0]  # Check first enemy only
	
	if not is_instance_valid(enemy):
		return
	
	print("\n[MOVEMENT DEBUG] Enemy: ", enemy.name)
	print("  Position: ", enemy.global_position)
	print("  Velocity: ", enemy.velocity)
	print("  Velocity length: ", enemy.velocity.length())
	
	if "_opponent" in enemy:
		print("  Opponent: ", enemy._opponent)
		if enemy._opponent:
			var dist = enemy.global_position.distance_to(enemy._opponent.global_position)
			print("  Distance to opponent: ", dist)
			
			# Check if navigation agent has a path
			if "navigation_agent" in enemy and enemy.navigation_agent:
				var nav = enemy.navigation_agent
				print("  Nav target: ", nav.target_position)
				print("  Nav finished: ", nav.is_navigation_finished())
				print("  Nav is_target_reachable: ", nav.is_target_reachable())
	
	if "_move_tier" in enemy:
		print("  Move Tier: ", enemy._move_tier)
	
	if "_blackboard" in enemy:
		var bb = enemy._blackboard
		print("  Blackboard opponent: ", bb.get("opponent", "NO KEY"))
		print("  Blackboard destination: ", bb.get("destination", "NO KEY"))
