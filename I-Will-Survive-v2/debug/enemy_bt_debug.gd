extends Node
## Debug script to monitor enemy behavior trees

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	check_enemy_bt_status()

func check_enemy_bt_status() -> void:
	print("\n=== ENEMY BEHAVIOR TREE DEBUG ===")
	
	var enemies := get_tree().get_nodes_in_group("enemies")
	print("Found ", enemies.size(), " enemies")
	
	if enemies.is_empty():
		print("ERROR: No enemies in scene!")
		return
	
	for i in mini(3, enemies.size()):  # Check first 3 enemies
		var enemy = enemies[i]
		print("\nEnemy #", i + 1, ": ", enemy.name)
		
		# Check if BTRunner exists
		if enemy.has_node("BTRunner"):
			var bt_runner = enemy.get_node("BTRunner")
			print("  ✓ BTRunner exists")
			print("    - Initialized: ", bt_runner._is_initialized)
			print("    - Tree: ", bt_runner.tree)
			print("    - Agent: ", bt_runner._agent)
			print("    - Tick interval: ", bt_runner.tick_interval)
			print("    - Physics processing: ", bt_runner.is_physics_processing())
			
			var blackboard = bt_runner.get_blackboard()
			print("    - Blackboard keys: ", blackboard.keys())
			print("    - Opponent: ", blackboard.get("opponent", "NOT SET"))
		else:
			print("  ✗ BTRunner NOT FOUND")
		
		# Check if enemy has opponent
		if "get_opponent" in enemy:
			print("  - Enemy opponent: ", enemy.get_opponent())
		elif "_opponent" in enemy:
			print("  - Enemy _opponent: ", enemy._opponent)
