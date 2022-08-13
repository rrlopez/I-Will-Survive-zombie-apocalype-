extends Area2D

var data = {}


func _ready():
	data = Utils.import_data("res://scene/maps/data/data.json")
	spawnEnemies()
	add_child(Factory.enemies.create('normal', 0, 0, 0))
	

func spawnEnemies():
	var size = $Collider.shape.extents
	
	for enemy in Factory.enemies.createMany(size, data.enemies):
		add_child(enemy)
	
