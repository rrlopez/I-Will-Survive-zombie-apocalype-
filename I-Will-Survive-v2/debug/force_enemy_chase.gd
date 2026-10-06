extends Node
## Force enemies to chase player directly (bypass BT for testing)

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	force_chase()

func _process(_delta: float) -> void:
	# Continuously check for enemies without opponents
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		if "_opponent" in enemy and enemy._opponent == null:
			if Globals.player and is_instance_valid(Globals.player):
				# Set opponent for enemies that don't have one
				if enemy.has_method("set_opponent"):
					enemy.set_opponent(Globals.player)

func force_chase() -> void:
	print("\n=== FORCING ENEMIES TO CHASE PLAYER ===")
	
	var enemies := get_tree().get_nodes_in_group("enemies")
	print("Found ", enemies.size(), " enemies")
	
	if not Globals.player:
		print("ERROR: No player found!")
		return
	
	print("Player at: ", Globals.player.global_position)
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# Directly set opponent
		if enemy.has_method("set_opponent"):
			enemy.set_opponent(Globals.player)
			print("Set opponent for ", enemy.name)
		
		# Also set in blackboard if accessible
		if "_blackboard" in enemy:
			enemy._blackboard["opponent"] = Globals.player
			print("Set blackboard opponent for ", enemy.name)
	
	print("All enemies should now chase player!")
	print("If they still don't move, the movement system itself has an issue.")
