extends Area2D

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
	var enemyRemaining =  enemyCount()
	if visible and enemyRemaining<totalEnemy:
		var count = totalEnemy-enemyRemaining
		var size = $Collider.shape.extents
		for enemy in Factory.enemies.createMany(size, data.enemies):
			enemy.global_position = enemy.position+global_position
			enemies.append(enemy)
			Globals.mapManager.enemies.add_child(enemy)
			count+=1
			if count > totalEnemy: return

func enemyCount():
	for enemy in enemies:
		if !weakref(enemy).get_ref(): enemies.erase(enemy)
	return enemies.size()


func _on_visibility_screen_entered():
	Globals.mapManager.dayNightCycle.connect("dayStarted", self, "spawnEnemies")
	show()
	spawnEnemies()


func _on_visibility_screen_exited():
	Globals.mapManager.dayNightCycle.disconnect("dayStarted", self, "spawnEnemies")
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
