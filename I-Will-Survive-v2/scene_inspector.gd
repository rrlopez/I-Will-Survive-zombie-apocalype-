extends Node
## Inspects your scene to show what's there and help debug.

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	inspect_scene()

func inspect_scene() -> void:
	print("\n" + "="*60)
	print("SCENE INSPECTOR")
	print("="*60)
	
	# Find GameState or root
	var game_state = get_tree().root.get_node_or_null("GameState")
	var root = game_state if game_state else get_tree().root
	
	print("\nROOT NODE: ", root.name)
	print("\nCHILDREN IN SCENE:")
	print_tree(root, 0)
	
	# Check for spawners
	print("\n" + "="*60)
	print("SPAWNER CHECK:")
	print("="*60)
	
	var has_test_spawner = find_node_with_script(root, "test_enemy_spawn.gd")
	var has_continuous = find_node_with_script(root, "continuous_enemy_spawner.gd")
	var has_area = find_node_with_script(root, "area_enemy_spawner.gd")
	
	if has_test_spawner:
		print("✓ Found TestEnemySpawner")
	else:
		print("✗ NO TestEnemySpawner found")
	
	if has_continuous:
		print("✓ Found ContinuousSpawner")
	else:
		print("✗ NO ContinuousSpawner found")
	
	if has_area:
		print("✓ Found AreaSpawner")
	else:
		print("✗ NO AreaSpawner found")
	
	if not has_test_spawner and not has_continuous and not has_area:
		print("\n⚠️  NO SPAWNERS FOUND IN SCENE!")
		print("\n📋 TO FIX:")
		print("1. Open your GameState scene")
		print("2. Add a Node")
		print("3. Attach one of these scripts:")
		print("   - test_enemy_spawn.gd")
		print("   - continuous_enemy_spawner.gd")
		print("   - area_enemy_spawner.gd")
		print("4. Save scene")
		print("5. Run game again")
	
	# Check for enemies
	print("\n" + "="*60)
	print("ENEMY CHECK:")
	print("="*60)
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Enemies in scene: ", enemies.size())
	
	if enemies.size() == 0:
		print("✗ NO ENEMIES - This is why you don't see any!")
	
	print("\n" + "="*60)

func print_tree(node: Node, depth: int) -> void:
	var indent = "  ".repeat(depth)
	var script_name = ""
	if node.get_script():
		var script = node.get_script()
		if script:
			var path = script.resource_path
			script_name = " [" + path.get_file() + "]"
	
	print(indent + "- " + node.name + script_name)
	
	# Only go 3 levels deep
	if depth < 3:
		for child in node.get_children():
			print_tree(child, depth + 1)

func find_node_with_script(root: Node, script_name: String) -> bool:
	if root.get_script():
		var script = root.get_script()
		if script and script.resource_path.ends_with(script_name):
			return true
	
	for child in root.get_children():
		if find_node_with_script(child, script_name):
			return true
	
	return false
