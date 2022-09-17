extends Area2D

export(NodePath) onready var enemies  = get_node(enemies) as Node2D
export(NodePath) onready var loots  = get_node(loots) as Node2D
export(NodePath) onready var objects  = get_node(objects) as Node2D

var day
var totalEnemy = 0
var totalLoot = 0

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


func spawner(_day=0):
	if day == _day || objects.get_child_count()>data.capacity: return
	day = _day
	spawnEnemies(_day)
	spawnLoots(_day)
	
	
func spawnEnemies(_day=0):
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

func spawnLoots(_day=0):
	if visible:
		var size = $Collider.shape.extents
		for drop in Globals.mapManager.spawnDropItems(data.loots.duplicate(true)):
			Constants.rand.randomize()
			var x = Constants.rand.randf_range(-size.x, size.x)
			Constants.rand.randomize()
			var y = Constants.rand.randf_range(-size.y, size.y)
			drop.position = Vector2(x, y)
			loots.add_child(drop)

func _on_visibility_screen_entered():
	Globals.dayNightCycle.connect("dayStarted", self, "spawner")
	show()
	spawner()


func _on_visibility_screen_exited():
	Globals.dayNightCycle.disconnect("dayStarted", self, "spawner")
	hide()
	


func _on_House_body_entered(_body):
	Globals.curHouse = self


func _on_House_body_exited(_body):
	if Globals.curHouse == self: Globals.curHouse = null



func serialize(savedData):
	savedData.updateOnly.append({
		"path" : get_path(),
		"day": day
	})


func deserialize(savedData):
	day = savedData.day

