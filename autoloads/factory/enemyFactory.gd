class_name EnemyFactory extends Node

var enemyScene = preload("res://scene/entities/enemies/Enemy.tscn")

var behaviors = {
	"basic": preload("res://ai/BasicAI.tscn"),
	"chase": preload("res://ai/ChaseAI.tscn")
}

var enemies = {}

func _init():
	for enemy in Utils.import_data("res://scene/entities/enemies/data/data.json"):
		enemies[enemy.static_data.id] = enemy
	
func data(name):
	var data = {
		"static": enemies[name].static_data,
		"states": {
			"isChasing": false,
			"isAttacking": false,
			"isIdle": false,
			"isDead": false
		}
	}
	if enemies[name].has("dynamic_data"):
		var dynamicData = enemies[name].dynamic_data.duplicate(true)
		for key in dynamicData.keys():
			data[key] = dynamicData[key]
	return data
	
	
func create(name, x, y, rotation):
	var enemy = enemyScene.instance()
	enemy.data = data(name)
	enemy.position = Vector2(x, y)
	enemy.rotation = rotation
	return enemy
	
	
func createMany(size, enemiesData):
	var enemies = []
	var rand = RandomNumberGenerator.new()
	
	for data in enemiesData:
		for _i in range(0, data.count):
			rand.randomize()
			var x = rand.randf_range(-size.x, size.x)
			rand.randomize()
			var y = rand.randf_range(-size.y, size.y)
			rand.randomize()
			var _rotation = rand.randf_range(0, 360)
			
			enemies.append(create(data.type, x, y, _rotation))
	
	return enemies
