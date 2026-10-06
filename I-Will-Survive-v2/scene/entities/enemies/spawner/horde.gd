class_name HordeSpawner extends Area2D
## Horde spawner — scattered spawn of multiple enemies within a radius.
## Spawns on _ready() and then removes itself from the tree.

@export var enemy_type: String = "zombie"  ## Enemy type ID from enemies.json
@export var count: int = 5                 ## Number of enemies to spawn
@export var spawn_radius: float = 200.0   ## Radius to scatter spawns within

func _ready() -> void:
	# Defer spawn to next frame to ensure Factory is ready
	call_deferred("_spawn_horde")

func _spawn_horde() -> void:
	# Access enemy factory from Factory autoload
	if not Factory or not Factory.enemies:
		push_warning("HordeSpawner: Factory.enemies not available")
		queue_free()
		return
	
	# Calculate scatter rect from position and radius
	var scatter_rect := Rect2(
		global_position.x - spawn_radius,
		global_position.y - spawn_radius,
		spawn_radius * 2.0,
		spawn_radius * 2.0
	)
	
	# Spawn enemies using factory
	var enemies: Array = Factory.enemies.create_many_enemies(count, enemy_type, scatter_rect)
	
	# Parent enemies to the spawner's parent (not to spawner itself)
	var parent_node := get_parent()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is Node:
			parent_node.add_child(enemy)
	
	# Remove spawner from tree
	queue_free()
