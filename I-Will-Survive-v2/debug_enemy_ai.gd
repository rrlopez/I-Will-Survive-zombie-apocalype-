extends Node
## Debug script to diagnose enemy AI issues.
## Attach this to a Node in your scene and run the game.

func _ready() -> void:
	# Wait a bit for everything to initialize
	await get_tree().create_timer(1.0).timeout
	_run_diagnostics()

func _run_diagnostics() -> void:
	print("=== ENEMY AI DIAGNOSTICS ===")
	
	# Check for player
	print("\n1. PLAYER CHECK:")
	if Globals.player and is_instance_valid(Globals.player):
		print("  ✓ Globals.player exists: ", Globals.player)
		if Globals.player:
			print("  ✓ Player is valid")
			print("  ✓ Player position: ", Globals.player.global_position if Globals.player is Node2D else "N/A")
	else:
		print("  ✗ Globals.player NOT found")
	
	var players := get_tree().get_nodes_in_group("player")
	print("  Players in 'player' group: ", players.size())
	if not players.is_empty():
		print("  ✓ First player: ", players[0])
	
	# Check for enemies
	print("\n2. ENEMY CHECK:")
	var enemies := get_tree().get_nodes_in_group("enemies")
	print("  Enemies in scene: ", enemies.size())
	
	if enemies.is_empty():
		print("  ✗ NO ENEMIES FOUND - This is the problem!")
		print("  → Check if enemies are being spawned")
		print("  → Check Factory.enemies.create_enemy() is being called")
	else:
		print("  ✓ Found ", enemies.size(), " enemies")
		
		# Check first enemy details
		var enemy = enemies[0]
		print("\n3. FIRST ENEMY DETAILS:")
		print("  Position: ", enemy.global_position if enemy is Node2D else "N/A")
		print("  Has BTRunner: ", enemy.has_node("BTRunner"))
		
		if enemy.has_node("BTRunner"):
			var bt_runner = enemy.get_node("BTRunner")
			print("  BTRunner tree: ", bt_runner.tree)
			print("  BTRunner tick_interval: ", bt_runner.tick_interval)
			print("  BTRunner physics_processing: ", bt_runner.is_physics_processing())
			
			# Check blackboard
			var bb = bt_runner.get_blackboard()
			print("\n4. BLACKBOARD STATE:")
			print("  Opponent: ", bb.get(BlackboardKeys.OPPONENT))
			print("  Destination: ", bb.get(BlackboardKeys.DESTINATION))
			print("  Attack Timer: ", bb.get(BlackboardKeys.ATTACK_TIMER))
		
		# Check enemy methods
		print("\n5. ENEMY CAPABILITIES:")
		print("  Has set_opponent: ", enemy.has_method("set_opponent"))
		print("  Has can_see_target: ", enemy.has_method("can_see_target"))
		print("  Has NavigationAgent2D: ", enemy.has_node("NavigationAgent2D"))
		
		if enemy.has_node("NavigationAgent2D"):
			var nav = enemy.get_node("NavigationAgent2D")
			print("  Nav target: ", nav.target_position)
			print("  Nav is_navigation_finished: ", nav.is_navigation_finished())
	
	print("\n=== END DIAGNOSTICS ===")

func _process(_delta: float) -> void:
	# Continuous monitoring (every 2 seconds)
	if Engine.get_frames_drawn() % 120 == 0:
		var enemies := get_tree().get_nodes_in_group("enemies")
		if not enemies.is_empty():
			var enemy = enemies[0]
			if enemy.has_node("BTRunner"):
				var bt_runner = enemy.get_node("BTRunner")
				var bb = bt_runner.get_blackboard()
				var opponent = bb.get(BlackboardKeys.OPPONENT)
				print("[Frame ", Engine.get_frames_drawn(), "] Enemy opponent: ", opponent, " | Tick: ", bt_runner.tick_interval)
