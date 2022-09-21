extends Node2D

export(NodePath) onready var enemiesContainer  = get_node(enemiesContainer) as Node2D
export(NodePath) onready var lootsContainer  = get_node(lootsContainer) as Node2D
export(NodePath) onready var objectsContainer  = get_node(objectsContainer) as Node2D

var day
var totalEnemy = 0

export(int) var capacity = 10

export(String, MULTILINE) var enemies = "[" \
+ "\n{\"type\": \"normal\", \"count\": 5}," \
+ "\n{\"type\": \"charger\", \"count\": 1}" \
+ "\n]"

export(String, MULTILINE) var loots = "[" \
+  "\n{ \"name\": \"machine gun ammo\", \"quantity\": {\"min\": 1, \"max\": 2}, \"rarity\": 100, \"life\": 500}," \
+  "\n{ \"name\": \"bandage\", \"quantity\": {\"min\": 1, \"max\": 2}, \"rarity\": 100, \"life\": 500}" \
+ "\n]"

func _init():
	enemies = JSON.parse(enemies).result
	loots = JSON.parse(loots).result

func _ready():
	Globals.currentMap.connect("onReady", self, "init", [], CONNECT_ONESHOT)
	for enemy in enemies:
		totalEnemy+=enemy.count


func init():
	$House/visibility.connect("screen_entered", self, "_on_visibility_screen_entered")
	$House/visibility.connect("screen_exited", self, "_on_visibility_screen_exited")


func spawner(_day=0):
	if day == _day || objectsContainer.get_child_count()>capacity: return
	day = _day
	spawnEnemies(_day)
	spawnLoots(_day)
	
	
func spawnEnemies(_day=0):
	var enemyRemaining =  enemiesContainer.get_child_count()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var size = $House/collider.shape.extents
		var enemiesData = enemies.duplicate(true)
		for enemyData in enemiesData:
			enemyData.count = min(enemyData.count, count)
			count-=enemyData.count
		for enemy in Factory.enemies.createMany(size, enemiesData):
			enemiesContainer.add_child(enemy)
			enemy.init()

func spawnLoots(_day=0):
	if visible:
		var size = $House/collider.shape.extents
		for drop in Globals.mapManager.spawnDropItems(loots.duplicate(true)):
			Constants.rand.randomize()
			var x = Constants.rand.randf_range(-size.x, size.x)
			Constants.rand.randomize()
			var y = Constants.rand.randf_range(-size.y, size.y)
			drop.position = Vector2(x, y)
			lootsContainer.add_child(drop)

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

