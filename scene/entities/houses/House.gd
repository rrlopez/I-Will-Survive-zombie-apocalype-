extends Area2D

export(NodePath) onready var enemies  = get_node(enemies) as Node2D

var day
var totalEnemy = 0

var data = {
	"disabled": false
}

func _ready():
	Globals.currentMap.connect("onReady", self, "init", [], CONNECT_ONESHOT)
	data = Factory.houses.create('normal')
	for enemy in data.enemies:
		totalEnemy+=enemy.count


func init():
	$visibility.connect("screen_entered", self, "_on_visibility_screen_entered")
	$visibility.connect("screen_exited", self, "_on_visibility_screen_exited")


func spawnEnemies(_day=0):
	if day == _day: return
	day = _day
	var enemyRemaining =  enemies.get_child_count()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var size = $Collider.shape.extents
		var enemiesData = data.enemies.duplicate(true)
		for enemyData in enemiesData:
			enemyData.count = min(enemyData.count, count)
			count-=enemyData.count
		for enemy in Factory.enemies.createMany(size, enemiesData):
			enemies.add_child(enemy)
			enemy.init()

func _on_visibility_screen_entered():
	Globals.dayNightCycle.connect("dayStarted", self, "spawnEnemies")
	show()
	spawnEnemies()


func _on_visibility_screen_exited():
	Globals.dayNightCycle.disconnect("dayStarted", self, "spawnEnemies")
	hide()

