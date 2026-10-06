extends Node
## Test script to spawn enemies for testing.
## Attach this to any Node in your game scene.

@export var spawn_count: int = 15  # More enemies!
@export var spawn_radius: float = 500.0  # Wider spread
@export var enemy_type: String = "normal"  # or "charger"
@export var auto_spawn_on_ready: bool = true  # Spawn automatically

func _ready() -> void:
	# Wait for player and world to be ready
	await get_tree().create_timer(0.5).timeout
	
	if auto_spawn_on_ready:
		spawn_test_enemies()

func spawn_test_enemies() -> void:
	print("\n=== SPAWNING TEST ENEMIES ===")
	
	# Check if Factory is available
	if not Factory or not Factory.enemies:
		push_error("Factory.enemies not available!")
		return
	
	# Get player position as spawn center
	var spawn_center := Vector2.ZERO
	
	if Globals.player and is_instance_valid(Globals.player):
		if Globals.player is Node2D:
			spawn_center = Globals.player.global_position
			print("Spawning enemies around player at: ", spawn_center)
	else:
		print("WARNING: No player found, spawning at origin")
	
	# Spawn enemies in a circle around spawn center (OUTSIDE, not inside)
	var parent := get_tree().root.get_node("GameState") if get_tree().root.has_node("GameState") else get_tree().root
	
	for i in spawn_count:
		var angle := (TAU / spawn_count) * i
		var offset := Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos := spawn_center + offset
		
		print("Creating enemy ", i + 1, " at ", spawn_pos)
		var enemy = Factory.enemies.create_enemy(enemy_type, spawn_pos, angle)
		
		if enemy:
			parent.add_child(enemy)
			print("  ✓ Enemy created and added to scene: ", enemy.name)
			print("  ✓ Enemy position: ", enemy.global_position)
			
			# Add debug visual
			var debug_visual = preload("res://enemy_debug_visual.gd").new()
			enemy.add_child(debug_visual)
			
			# Debug: Check if BTRunner has tree
			if enemy.has_node("BTRunner"):
				var bt = enemy.get_node("BTRunner")
				print("  ✓ BTRunner tree: ", bt.tree)
				if bt.tree:
					print("  ✓ Tree root: ", bt.tree.root)
			else:
				print("  ✗ No BTRunner found!")
		else:
			print("  ✗ Failed to create enemy!")
	
	print("=== SPAWN COMPLETE: ", spawn_count, " enemies spawned ===\n")
	print("HINT: Enemies have BIG RED CIRCLES and YELLOW LABELS above them!")

func _input(event: InputEvent) -> void:
	# Press T to spawn more enemies
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		spawn_test_enemies()
