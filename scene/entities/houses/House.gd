extends Area2D

var day
var enemies = []
var totalEnemy = 0

var data = {
	"disabled": false
}

func _ready():
	data = Factory.houses.create('normal')
	for enemy in data.enemies:
		totalEnemy+=enemy.count


func spawnEnemies(_day=0):
	if day == _day: return
	day = _day
	var enemyRemaining =  enemyCount()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var size = $Collider.shape.extents
		var enemiesData = data.enemies.duplicate(true)
		for data in enemiesData:
			data.count = min(data.count, count)
			count-=data.count
		for enemy in Factory.enemies.createMany(size, enemiesData):
			enemy.global_position = enemy.global_position+global_position
			enemies.append(enemy)

func enemyCount():
	for enemy in enemies:
		if !weakref(enemy).get_ref(): enemies.erase(enemy)
	return enemies.size()


func _on_visibility_screen_entered():
	Globals.dayNightCycle.connect("dayStarted", self, "spawnEnemies")
	show()
	spawnEnemies()


func _on_visibility_screen_exited():
	Globals.dayNightCycle.disconnect("dayStarted", self, "spawnEnemies")
	hide()


func _on_visibility_viewport_entered(viewport):
	if viewport.name == 'root':
		$visibility.connect("screen_entered", self, "_on_visibility_screen_entered")
		$visibility.connect("screen_exited", self, "_on_visibility_screen_exited")
		self.connect("body_entered", $Roof, "_on_House_body_entered")
		self.connect("body_exited", $Roof, "_on_House_body_exited")
		$visibility.connect("screen_exited", self, "_on_visibility_screen_exited")
		_on_visibility_screen_entered()
	elif viewport.name == 'minmapViewport': $Roof.hide()
	
	$visibility.disconnect("viewport_entered", self, "_on_visibility_viewport_entered")


func _on_House_tree_exiting():
	for enemy in enemies:
		if weakref(enemy).get_ref(): enemy.queue_free()
