extends Node2D

var data = {
	"disabled": false
}

var day
var totalEnemy = 0
var size

func _ready():
	data = Factory.houses.create('normal')
	for enemy in data.enemies:
		totalEnemy+=enemy.count

func spawnEnemies(_day=0):
	if day == _day: return
	day = _day
	var enemyRemaining =  get_child_count()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var enemiesData = data.enemies.duplicate(true)
		for enemyData in enemiesData:
			enemyData.count = min(enemyData.count, count)
			count-=enemyData.count
		for enemy in Factory.enemies.createMany(size, enemiesData):
			add_child(enemy)
			enemy.init()
