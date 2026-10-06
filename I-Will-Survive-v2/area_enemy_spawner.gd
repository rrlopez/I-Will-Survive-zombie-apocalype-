extends Node
## Area-based enemy spawner - populates different zones with enemies.
## Spawns enemies in grid pattern across the map.

@export var grid_size: int = 3000  # Total area to populate (3000x3000)
@export var cell_size: int = 500   # Size of each spawn cell
@export var enemies_per_cell: int = 2  # Enemies in each cell
@export var enemy_types: Array[String] = ["normal", "charger"]

func _ready() -> void:
	# Wait for game to initialize
	await get_tree().create_timer(1.0).timeout
	spawn_grid()

func spawn_grid() -> void:
	print("\n=== SPAWNING ENEMIES IN GRID PATTERN ===")
	
	if not Factory or not Factory.enemies:
		push_error("Factory not available!")
		return
	
	# Get player position as center
	var center := Vector2.ZERO
	if Globals.player and is_instance_valid(Globals.player):
		center = Globals.player.global_position
	
	var half_grid := grid_size / 2
	var cells_per_side := grid_size / cell_size
	var total_spawned := 0
	
	# Create grid
	for x in range(-cells_per_side / 2, cells_per_side / 2):
		for y in range(-cells_per_side / 2, cells_per_side / 2):
			# Cell center position
			var cell_center := center + Vector2(x * cell_size, y * cell_size)
			
			# Skip cell if too close to player
			if cell_center.distance_to(center) < 200:
				continue
			
			# Spawn enemies in this cell
			for i in enemies_per_cell:
				var offset := Vector2(
					randf_range(-cell_size * 0.4, cell_size * 0.4),
					randf_range(-cell_size * 0.4, cell_size * 0.4)
				)
				var spawn_pos := cell_center + offset
				
				if spawn_enemy_at(spawn_pos):
					total_spawned += 1
	
	print("Grid spawn complete: ", total_spawned, " enemies across map")
	print("Press K to clear enemies, L to spawn burst of 10")

func spawn_enemy_at(pos: Vector2) -> bool:
	# Pick random enemy type
	var enemy_type := enemy_types[randi() % enemy_types.size()] if not enemy_types.is_empty() else "normal"
	
	# Create enemy
	var enemy = Factory.enemies.create_enemy(enemy_type, pos, randf() * TAU)
	
	if enemy:
		var parent := get_tree().root.get_node("GameState") if get_tree().root.has_node("GameState") else get_tree().root
		parent.add_child(enemy)
		
		# Add debug visual
		var debug_visual = load("res://enemy_debug_visual.gd").new()
		enemy.add_child(debug_visual)
		
		return true
	
	return false
