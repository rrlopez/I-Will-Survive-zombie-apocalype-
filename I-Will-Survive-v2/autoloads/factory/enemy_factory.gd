extends RefCounted
## EnemyFactory — instantiates enemy scenes from data.
## Reads enemies.json, preloads base scene and resources, creates configured enemies.

# ── Cached Data ───────────────────────────────────────────────────────────────
var _enemy_data: Dictionary = {}
var _base_scene: PackedScene = null
var _attack_classes: Dictionary = {}

# ── Initialization ────────────────────────────────────────────────────────────

func _init() -> void:
	_load_data()
	_preload_resources()

func _load_data() -> void:
	var file_path := "res://data/enemies.json"
	if not FileAccess.file_exists(file_path):
		push_error("EnemyFactory: enemies.json not found at %s" % file_path)
		return
	
	var json_text := FileAccess.get_file_as_string(file_path)
	var json_result = JSON.parse_string(json_text)
	
	# Handle both legacy array format and new {"enemies": []} format
	var enemies_array: Array = []
	if json_result is Array:
		enemies_array = json_result
	elif json_result is Dictionary and json_result.has("enemies"):
		enemies_array = json_result["enemies"]
	
	# Parse enemy definitions (handles legacy static_data/dynamic_data format)
	for enemy_def in enemies_array:
		if not enemy_def is Dictionary:
			continue
		
		# Extract ID from either static_data or direct id field
		var enemy_id: String = ""
		if enemy_def.has("static_data") and enemy_def["static_data"].has("id"):
			enemy_id = enemy_def["static_data"]["id"]
		elif enemy_def.has("id"):
			enemy_id = enemy_def["id"]
		
		if not enemy_id.is_empty():
			_enemy_data[enemy_id] = enemy_def
	
	print("EnemyFactory: Loaded %d enemy types" % _enemy_data.size())

func _preload_resources() -> void:
	# Preload base enemy scene
	_base_scene = preload("res://scene/entities/enemies/enemy.tscn")
	
	# Preload attack classes
	_attack_classes["melee"] = MeleeAttack
	_attack_classes["charge"] = ChargeAttack
	
	# Preload additional resources (sprites, sounds) will be added in Phase 15/17

# ── Public API ────────────────────────────────────────────────────────────────

## Create a single enemy by type ID at given position and rotation.
## Returns Enemy node or null if type not found.
func create_enemy(type_id: String, position: Vector2 = Vector2.ZERO, rotation: float = 0.0) -> Enemy:
	if not _enemy_data.has(type_id):
		push_warning("EnemyFactory: Unknown enemy type '%s'" % type_id)
		return null
	
	if not _base_scene:
		push_error("EnemyFactory: Base enemy scene not loaded")
		return null
	
	var enemy_def: Dictionary = _enemy_data[type_id]
	var enemy: Enemy = _base_scene.instantiate() as Enemy
	
	if not enemy:
		push_error("EnemyFactory: Failed to instantiate enemy scene")
		return null
	
	# Set transform
	enemy.global_position = position
	enemy.rotation = rotation
	
	# Store enemy definition as metadata for deferred configuration
	enemy.set_meta("enemy_definition", enemy_def)
	
	# Configure attack from enemy definition (doesn't need stats)
	_configure_attack(enemy, enemy_def)
	
	# Configure behavior tree (doesn't need stats)
	_configure_behavior_tree(enemy, enemy_def)
	
	return enemy

## Create multiple enemies scattered within a rectangle.
## Returns Array of Enemy nodes.
func create_many_enemies(count: int, type_id: String, scatter_rect: Rect2) -> Array:
	var enemies: Array = []
	
	for i in count:
		var random_pos := Vector2(
			randf_range(scatter_rect.position.x, scatter_rect.position.x + scatter_rect.size.x),
			randf_range(scatter_rect.position.y, scatter_rect.position.y + scatter_rect.size.y)
		)
		var random_rot := randf() * TAU
		
		var enemy := create_enemy(type_id, random_pos, random_rot)
		if enemy:
			enemies.append(enemy)
	
	return enemies

# ── Internal Configuration ────────────────────────────────────────────────────

func _configure_stats(enemy: Enemy, enemy_def: Dictionary) -> void:
	if not enemy.stats:
		return
	
	# Get stats data from enemy definition (handles legacy dynamic_data format)
	var stats_data: Dictionary = {}
	if enemy_def.has("dynamic_data") and enemy_def["dynamic_data"].has("stats"):
		stats_data = enemy_def["dynamic_data"]["stats"]
	elif enemy_def.has("stats"):
		stats_data = enemy_def["stats"]
	
	# Configure each stat via StatsComponent
	for stat_name in stats_data.keys():
		var stat_value = stats_data[stat_name]
		
		# Try both the original name and the "script" name
		var script_name = stat_value.get("script", stat_name) if stat_value is Dictionary else stat_name
		
		# Try multiple name variations
		var names_to_try = [stat_name, script_name]
		
		for name in names_to_try:
			if enemy.stats.has_stat(name):
				var stat = enemy.stats.get_stat(name)
				if stat:
					# Handle legacy format with "val" field or direct value
					if stat_value is Dictionary:
						var base_val = stat_value.get("val", 0.0)
						if base_val is float or base_val is int:
							stat.base_value = float(base_val)
							break
					else:
						stat.base_value = float(stat_value)
						break

func _configure_attack(enemy: Enemy, enemy_def: Dictionary) -> void:
	# Get attack type from enemy definition (handles legacy attacks array format)
	var attack_type: String = "melee"  # default
	
	# Check legacy format with attacks array
	if enemy_def.has("dynamic_data") and enemy_def["dynamic_data"].has("attacks"):
		var attacks: Array = enemy_def["dynamic_data"]["attacks"]
		if not attacks.is_empty() and attacks[0] is Dictionary:
			var attack_script: String = attacks[0].get("script", "melle")
			# Map legacy script names to new attack types
			if attack_script == "charge":
				attack_type = "charge"
			elif attack_script == "melle" or attack_script == "melee":
				attack_type = "melee"
	elif enemy_def.has("attack_type"):
		attack_type = enemy_def["attack_type"]
	
	# Create attack instance
	if _attack_classes.has(attack_type):
		var attack_class = _attack_classes[attack_type]
		var attack_instance = attack_class.new()
		
		# Store attack instance (Phase 7 BT will use this)
		enemy.set_meta("default_attack", attack_instance)
	else:
		push_warning("EnemyFactory: Unknown attack type '%s' for enemy" % attack_type)


func _configure_behavior_tree(enemy: Enemy, enemy_def: Dictionary) -> void:
	# Get behavior type from enemy definition
	var behavior: String = "basic"  # default
	
	if enemy_def.has("dynamic_data") and enemy_def["dynamic_data"].has("behavior"):
		behavior = enemy_def["dynamic_data"]["behavior"]
	elif enemy_def.has("behavior"):
		behavior = enemy_def["behavior"]
	
	# Get BTRunner
	if not enemy.has_node("BTRunner"):
		print("WARNING: Enemy has no BTRunner node")
		return
	
	var bt_runner := enemy.get_node("BTRunner")
	if not bt_runner:
		print("WARNING: Could not get BTRunner")
		return
	
	# Assign behavior tree based on type
	var tree: BTTreeResource = null
	match behavior:
		"wander":
			tree = WanderTree.create()
			print("Assigned WanderTree to enemy")
		"chase":
			tree = ChaseTree.create()
			print("Assigned ChaseTree to enemy")
		"basic", _:
			tree = BasicAITree.create()
			print("Assigned BasicAITree to enemy")
	
	if tree:
		bt_runner.tree = tree
		print("BT tree assigned successfully. Root: ", tree.root)
	else:
		print("ERROR: Failed to create behavior tree!")


## Configure stats for an enemy that's already been added to the scene tree.
## Call this after the enemy's _ready() has completed.
func configure_enemy_stats(enemy: Enemy, enemy_def: Dictionary) -> void:
	_configure_stats(enemy, enemy_def)
