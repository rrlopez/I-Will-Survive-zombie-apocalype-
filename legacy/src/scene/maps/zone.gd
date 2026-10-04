extends Area2D

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var enemiesContainer  = get_node(enemiesContainer) as Node2D
export(NodePath) onready var lootsContainer  = get_node(lootsContainer) as Node2D

var day
var totalEnemy = 0


export(String, MULTILINE) var enemies = "[" \
+ "\n{\"type\": \"normal\", \"count\": 100}," \
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
	var _val = $visibility.connect("screen_entered", self, "_on_visibility_screen_entered")
	_val = $visibility.connect("screen_exited", self, "_on_visibility_screen_exited")
	for enemy in enemies: totalEnemy+=enemy.count
	
	
func spawner(_day=0):
	if day == _day: return
	day = _day
	spawnEnemies(_day)
	spawnLoots(_day)
	
	

func spawnEnemies(_day=0):
	var enemyRemaining =  enemiesContainer.get_child_count()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var size = collider.shape.extents
		var enemiesData = enemies.duplicate(true)
		for enemyData in enemiesData:
			enemyData.count = min(enemyData.count, count)
			count-=enemyData.count
		for enemy in Factory.enemies.createMany(size, enemiesData):
			enemiesContainer.add_child(enemy)
			enemy.init()
			enemy.global_position+=(collider.global_position-global_position)

func spawnLoots(_day=0):
	if visible:
		var size = collider.shape.extents
		for drop in Globals.mapManager.spawnDropItems(loots.duplicate(true)):
			Constants.rand.randomize()
			var x = Constants.rand.randf_range(-size.x, size.x)
			Constants.rand.randomize()
			var y = Constants.rand.randf_range(-size.y, size.y)
			drop.position = Vector2(x, y)+collider.global_position
			lootsContainer.add_child(drop)


func _on_visibility_screen_entered():
	Globals.dayNightCycle.connect("dayStarted", self, "spawner")
	$node.show()
	spawner()


func _on_visibility_screen_exited():
	Globals.dayNightCycle.disconnect("dayStarted", self, "spawner")
	$node.hide()



func serialize(savedData):
	savedData.updateOnly.append({
		"path" : get_path(),
		"day": day
	})

func deserialize(savedData):
	day = savedData.day
