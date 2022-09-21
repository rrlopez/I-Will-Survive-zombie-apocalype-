extends Area2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D


export(String, MULTILINE) var enemies = "[" \
+ "\n{\"type\": \"normal\", \"count\": 10}," \
+ "\n{\"type\": \"charger\", \"count\": 2}" \
+ "\n]"

export(String, MULTILINE) var loots = "[" \
+  "\n{ \"name\": \"machine gun ammo\", \"quantity\": {\"min\": 1, \"max\": 2}, \"rarity\": 100, \"life\": 500}," \
+  "\n{ \"name\": \"bandage\", \"quantity\": {\"min\": 1, \"max\": 2}, \"rarity\": 100, \"life\": 500}" \
+ "\n]"

func _init():
	enemies = JSON.parse(enemies).result
	loots = JSON.parse(loots).result
	
func _ready():
	spawnEnemies()
	
func spawnEnemies(_day=0):
	for enemy in Factory.enemies.createMany(collider.shape.extents, enemies):
		add_child(enemy)
		enemy.init()
		enemy.global_position+=+collider.global_position
