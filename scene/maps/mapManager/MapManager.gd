extends Node2D

onready var currentMapScene = preload("res://scene/maps/world.tscn")
onready	var enemyScene = load("res://scene/entities/enemies/Enemy.tscn")
onready	var soundScene = load("res://scene/entities/objects/sound/Sound.tscn")
onready var dropItemScene = preload("res://scene/entities/objects/dropItem/DropItem.tscn")



func _ready():
	createCamera()
	Globals.mapManager = self
	Globals.player = self.get_node("Player")
	Globals.player.addCamera()
	Globals.currentMap = currentMapScene.instance()
	Globals.currentNavigation = Globals.currentMap.get_node("Navigation")
	add_child(Globals.currentMap)


func spawnEnemies(size, count):
	var enemies = []
	var rand = RandomNumberGenerator.new()
	
	for _i in range(0, count):
		rand.randomize()
		var x = rand.randf_range(-size.x, size.x)
		rand.randomize()
		var y = rand.randf_range(-size.y, size.y)
		rand.randomize()
		var _rotation = rand.randf_range(0, 360)
		
		enemies.append(spawnEnemy(x, y, _rotation))
	
	return enemies


func spawnEnemy(x, y, rotation):
	var enemy = enemyScene.instance()
	enemy.data = Constants.get_enemies('normal')
	enemy.position.x = x
	enemy.position.y = y
	enemy.rotation = rotation

	return enemy
	
	
func spawnSound(origin, scale = 100):
	var sound = soundScene.instance()
	sound.scale = Vector2(scale/100, scale/100)
	sound.origin = origin
	add_child(sound) 


func spawnDropItems(items, position):
	for item in items: 
		Constants.rand.randomize()
		if Constants.rand.randi()%100<item.rarity: 
			Constants.rand.randomize()
			item.quantity = Constants.rand.randi_range(item.quantity.min, item.quantity.max)
			createItem(item, position)

func createItem(item, position):
	var dropItem = dropItemScene.instance()
	dropItem.global_position = position
	dropItem.data = Constants.get_item(item.name)
	item.quantity = dropItem.add_item_quantity(item.quantity)
	add_child(dropItem)
	if item.quantity > 0: createItem(item, position)


func spawnRays(width, height):
	var rays = []
	var ray_count = deg2rad(width) / Constants.ANGLE_BETWEEN_RAYS
	for i in ray_count:
		var ray = RayCast2D.new()
		var angle = Constants.ANGLE_BETWEEN_RAYS * (i - ray_count/2.0)
		ray.cast_to = Vector2.RIGHT.rotated(angle) * height
		rays.append(ray)
	return rays
	
	
func createCamera():
	var camera = Camera2D.new()
	camera.rotating = true
	camera.current = true
	Globals.camera = camera
