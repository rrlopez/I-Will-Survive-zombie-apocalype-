extends CanvasModulate

var time = 80
var speed = 0.2
var lastDay = 1
var waveCount = 0

signal dayStarted

func _init():
	Globals.dayNightCycle = self

func init():
	$Animation.play("cycle")
	$Animation.playback_speed = speed
	$Animation.seek(time)

func _process(delta):
	time = fmod(time+(speed*delta), 180)
	if(time<90): day(delta)


func day(_delta):
	var sunPosition = $AmbiantLight.global_position
	var shadows = self.get_tree().get_nodes_in_group('shadow')
	for shadow in shadows:
		var parent = shadow.get_parent()
		if(!parent.visible): continue
		var parentsPosition = parent.global_position
		var position = sunPosition+parentsPosition
		var distance = min(50, parentsPosition.distance_to(position)*0.3)
		var direction = position.direction_to(parentsPosition).rotated(deg2rad(-parent.rotation_degrees))
		
		shadow.position = Vector2(direction.x*distance, direction.y*distance)
		shadow.modulate.a = min(1, (0.5-abs(sin(deg2rad(time))-0.5))*4)
	
	$AmbiantLight.global_position = Vector2(((time-45)*5)+60, ((abs(sin(deg2rad(time))-0.5))*200)+10)


func dayStarted():
	lastDay+=1
	waveCount = 0
	emit_signal("dayStarted", lastDay)
	
	
func spawnEnemyWave():
	waveCount+=1
	Globals.HUD.notifs.addNotif("wave "+String(waveCount))
	for _i in 100:
		Constants.rand.randomize()
		var position = Globals.player.global_position + Vector2.UP.rotated(Constants.rand.randi_range(-360, 360))* Constants.rand.randi_range(Constants.WIDTH, Constants.WIDTH*1.7)
		var enemy = Factory.enemies.create('normal', position.x, position.y, 0)
		Globals.mapManager.enemies.add_child(enemy)
		enemy.init()
		enemy.behavior = "chase"



func serialize(savedData):
	savedData.others.append({
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"time":time,
		"speed": speed,
		"lastDay": lastDay,
		"waveCount": waveCount,
	})



func deserialize(savedData):
	time = savedData.time
	speed = savedData.speed
	lastDay = savedData.lastDay
	waveCount = savedData.waveCount
	init()
