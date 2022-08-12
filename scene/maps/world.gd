extends Area2D

var data = {}


func _ready():
	data = Utils.import_data("res://scene/maps/data/data.json")
	spawnEnemies()
	

func spawnEnemies():
	var size = $Collider.shape.extents
	
	for enemy in Globals.mapManager.spawnEnemies(size, data.enemies):
		add_child(enemy)
	
