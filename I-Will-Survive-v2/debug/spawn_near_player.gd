extends Node
## Emergency spawner - spawns enemies in a tight circle around the player
## Use this to immediately see enemies near you

@export var spawn_count: int = 10
@export var spawn_radius: float = 150.0  # Very close to player

func _ready() -> void:
	# Wait a moment for everything to initialize
	await get_tree().create_timer(1.5).timeout
	spawn_enemies_near_player()

func spawn_enemies_near_player() -> void:
	print("\n=== EMERGENCY SPAWN: Placing ", spawn_count, " enemies near player ===")
	
	# Get player position
	var player_pos := Vector2.ZERO
	if Globals.player and is_instance_valid(Globals.player):
		player_pos = Globals.player.global_position
		print("Player found at: ", player_pos)
	else:
		print("ERROR: Cannot find player!")
		return
	
	if not Factory or not Factory.enemies:
		print("ERROR: Factory not available!")
		return
	
	var spawned := 0
	
	# Spawn at random positions around player (200-700 distance, random angles)
	for i in spawn_count:
		var angle := randf() * TAU  # Random angle (0 to 360 degrees)
		var distance := randf_range(200.0, 700.0)  # Random distance
		var offset := Vector2(cos(angle), sin(angle)) * distance
		var spawn_pos := player_pos + offset
		
		# Use "charger" type which has "basic" behavior (chases player)
		var enemy = Factory.enemies.create_enemy("charger", spawn_pos, angle)
		
		if enemy:
			# Add to scene FIRST so @onready variables initialize
			get_tree().root.add_child(enemy)
			
			# Stats are now automatically configured in enemy._ready()
			
			# Add debug visual (big red circle)
			var debug_visual = load("res://enemy_debug_visual.gd").new()
			enemy.add_child(debug_visual)
			
			spawned += 1
			print("  Spawned enemy #", i + 1, " at ", spawn_pos, " (distance: ", player_pos.distance_to(spawn_pos), ")")
	
	print("Total spawned: ", spawned, "/", spawn_count)
	print("Press K to kill all, L to spawn 10 more, Mouse Wheel to zoom")

func _input(event: InputEvent) -> void:
	# Press K to kill all enemies
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		var enemies := get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			enemy.queue_free()
		print("Killed all ", enemies.size(), " enemies")
	
	# Press L to spawn more right next to player
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		spawn_enemies_near_player()
