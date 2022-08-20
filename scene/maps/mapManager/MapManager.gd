extends Node2D

onready var currentMapScene = preload("res://scene/maps/world.tscn")
onready	var soundScene = load("res://scene/entities/objects/sound/Sound.tscn")
onready var dropItemScene = preload("res://scene/entities/objects/dropItem/DropItem.tscn")
onready var CameraScene = preload("res://scene/entities/objects/camera/Camera.tscn")



func _ready():
	Globals.camera = CameraScene.instance()
	Globals.mapManager = self
	Globals.player = self.get_node("Player")
	Globals.player.addCamera()
	Globals.currentMap = currentMapScene.instance()
	Globals.currentNavigation = Globals.currentMap.get_node("Navigation")
	add_child(Globals.currentMap)

	
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
	dropItem.data = Factory.items.data(item.name)
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
