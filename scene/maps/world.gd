extends Area2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D

var data = {}


func _ready():
	data = Factory.maps.create("normal")
	spawnEnemies()
	add_child(Factory.enemies.create('normal', 0, 0, 0))
	

func spawnEnemies():
	var size = collider.shape.extents
	
	for enemy in Factory.enemies.createMany(size, data.enemies):
		add_child(enemy)
	
