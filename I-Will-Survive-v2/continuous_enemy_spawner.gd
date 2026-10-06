extends Node
## Continuous enemy spawner - maintains a target population across the map.
## Spawns enemies periodically to keep the world populated.

@export var target_enemy_count: int = 30  # Total enemies to maintain
@export var spawn_interval: float = 5.0   # Spawn new enemies every X seconds
@export var spawn_radius_min: float = 400.0  # Min distance from player
@export var spawn_radius_max: float = 800.0  # Max distance from player
@export var enemy_types: Array[String] = ["normal", "normal", "normal", "charger"]  # Weighted types

var spawn_timer: float = 0.0
var initial_spawn_done: bool = false

func _ready() -> void:
	# Wait for game to be ready
	await get_tree().create_timer(1.0).timeout
	
	# Initial population burst
	spawn_initial_population()
	initial_spawn_done = true
	
	print("Continuous spawner active - maintaining ", target_enemy_count, " enemies")

func _process(delta: float) -> void:
	if not initial_spawn_done:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		check_and_spawn()

func spawn_initial_population() -> void:
	print("\n=== SPAWNING INITIAL ENEMY POPULATION ===")
	
	var to_spawn := target_enemy_count
	var spawned := 0
	
	for i in to_spawn:
		if spawn_enemy_at_random_location():
			spawned += 1
	
	print("Initial spawn complete: ", spawned, "/", to_spawn, " enemies")

func check_and_spawn() -> void:
	var current_count := get_tree().get_nodes_in_group("enemies").size()
	
	if current_count < target_enemy_count:
		var to_spawn := mini(5, target_enemy_count - current_count)  # Spawn up to 5 at a time
		
		for i in to_spawn:
			spawn_enemy_at_random_location()

func spawn_enemy_at_random_location() -> bool:
	if not Factory or not Factory.enemies:
		return false
	
	# Get player position
	var center := Vector2.ZERO
	if Globals.player and is_instance_valid(Globals.player):
		center = Globals.player.global_position
	
	# Random position at distance from player
	var angle := randf() * TAU
	var distance := randf_range(spawn_radius_min, spawn_radius_max)
	var offset := Vector2(cos(angle), sin(angle)) * distance
	var spawn_pos := center + offset
	
	# Pick random enemy type (weighted)
	var enemy_type := enemy_types[randi() % enemy_types.size()] if not enemy_types.is_empty() else "normal"
	
	# Create enemy
	var enemy = Factory.enemies.create_enemy(enemy_type, spawn_pos, randf() * TAU)
	
	if enemy:
		# Add to scene
		var parent := get_tree().root.get_node("GameState") if get_tree().root.has_node("GameState") else get_tree().root
		parent.add_child(enemy)
		
		# Add debug visual
		var debug_visual = load("res://enemy_debug_visual.gd").new()
		enemy.add_child(debug_visual)
		
		return true
	
	return false

func _input(event: InputEvent) -> void:
	# Press K to kill all enemies (for testing)
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		var enemies := get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			enemy.queue_free()
		print("Killed all ", enemies.size(), " enemies - will respawn soon")
	
	# Press L to spawn burst
	if event is InputEventKey and event.pressed and event.keycode == KEY_L:
		for i in 10:
			spawn_enemy_at_random_location()
		print("Spawned 10 more enemies")
