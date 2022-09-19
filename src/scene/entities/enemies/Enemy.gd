class_name Enemy extends Entity

export(NodePath) onready var vision  = get_node(vision) as Node2D
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var sense  = get_node(sense) as CollisionShape2D
export(NodePath) onready var blockerSensor  = get_node(blockerSensor) as RayCast2D
export(NodePath) onready var attackRange  = get_node(attackRange) as RayCast2D
export(NodePath) onready var soundGrowl  = get_node(soundGrowl) as AudioStreamPlayer2D
export(NodePath) onready var hitBox  = get_node(hitBox) as Area2D

var body = null

var isPathGenerated = false
var path: Array = []
var velocity: Vector2 = Vector2.ZERO
var destination = Vector2.ZERO

var opponent = []
var behavior = null setget setBehavior

var attacks = []
var curAttack = null
var attackTimer = 0


	
func init():
	body = Factory.enemies.bodies[data.static.id].instance()
	add_child(body)
	.init()
	recomputeStats()
	soundGrowl.stream = Factory.enemies.growl[data.growl]
	if(global_position.distance_to(Globals.camera.global_position)>Constants.WIDTH): 
		visible = false
		setEnableVision(false)
	setBehavior(data.behavior)
	
	for attack in data.attacks: attacks.append(Factory.enemies.attacks[attack.script].new(self, attack))
	
		
func _physics_process(delta):
	process(delta)
	velocity = move_and_slide((applyedForce+velocity)*delta)
	
	
func process(delta):
	behavior.run(delta)
	
	if body.lowerBodyAnimation.is_playing(): move(delta)
	
	growl()
	._process(delta)
	
func generatePath():
	var destination = getDestination()
	path = Globals.curRegion.navigation.get_simple_path(global_position, destination, true)
	path.pop_front()
	isPathGenerated = true


func move(delta):
	if path.size() > 0:
		velocity = global_position.direction_to(path[0]).normalized() * data.stats.move_speed.val*Constants.MOVE_SPEED_MULTIPLYER
		
		var direction = (path[0] - global_position)
		var angleTo = self.transform.x.angle_to(direction)
		self.rotate(sign(angleTo) * min(delta*data.stats.angle_speed.val, abs(angleTo)))
		
		if global_position.distance_to(path[0])<10: path.pop_front()
	
	return path.size() > 0
			
func setEnableVision(enabled = self.visible):
	for ray in $Vision.get_children():
		ray.enabled = enabled


func hurt(_opponent, dmg):
	Factory.particles.createBlood(global_position, Color.green)
	if ._hurt(dmg): return data.stats.exp.val
	
	_on_View_body_entered(_opponent)
	return false

func dead():
	for drop in Globals.mapManager.spawnDropItems(data.drops, global_position):
		 Globals.mapManager.add_child(drop)
	queue_free()
	
func healthStatCallback(health):
	if(health.val<=0): dead()
	pass
	
func chooseAttack():
	Constants.rand.randomize()
	attacks[Constants.rand.randi_range(0, attacks.size()-1)].use()
		
func attack():
	body.lowerBodyAnimation.stop()
	path = []
	curAttack.attack()

func isAttacking(delta):
	return curAttack.isAttacking(delta)

func attackLanded():
	curAttack.landed()


func setBehavior(value):
	data.behavior = value
	behavior = Factory.enemies.behaviors[value].instance()
	behavior.start(self)
	

func growl():
	if !soundGrowl.is_playing():
		Constants.rand.randomize()
		if (Constants.rand.randi()%1000)<10: soundGrowl.play()

func getDestination():
	if opponent.empty() or opponent[0] == null or !weakref(opponent[0]).get_ref(): return destination
	return opponent[0].global_position
 
#---------- CONNECT FUNCTIONS --------------#

func _on_View_body_entered(_opponent):
	chooseAttack()
	$bodySensor/Collider.shape.radius = data.stats.aggression_range.val
	$Sense/Collider.disabled = true
	setEnableVision(false)
	opponent = [_opponent]
	attackRange.set_collision_mask_bit(2, false)


func _on_View_body_exited(_body):
	$bodySensor/Collider.shape.radius = 0
	$Sense/Collider.disabled = false
	$Body/Lower/Animation.stop()
	setEnableVision()
	path = []
	opponent = []


func _on_visibility_screen_entered():
	self.add_to_group("serializable")
	self.visible = true
	setEnableVision()


func _on_visibility_screen_exited():
	self.visible = false
	if opponent.empty():
		self.remove_from_group("serializable")
		$visibility.process_parent = true
		$visibility.physics_process_parent = true
	else:
		$visibility.process_parent = false
		$visibility.physics_process_parent = false
	setEnableVision()


func _on_bodySensor_body_entered(_opponent):
	if(!opponent.empty() and _opponent.opponent.empty()): _opponent._on_View_body_entered(opponent[0])


func _on_area_area_entered(_area):
	if(velocity.length()>1):
		var savedPosition = self.global_position
		var parent = get_parent()
		parent.remove_child(self)
		Globals.mapManager.add_child(self)
		self.global_position = savedPosition
		$area.disconnect("area_entered", self, "_on_area_area_entered")



func serialize(savedData):
	var serializedData = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"global_position":{
			"x": global_position.x,
			"y": global_position.y
		},
		"global_rotation_degrees": global_rotation_degrees,
		"statusEffects": statusEffects.serialize(),
		"id": data.static.id,
		"growl": data.growl,
		"stats": {},
	}
	
	for stat in data.stats: 
		serializedData.stats[stat] = data.stats[stat].serialize()
	
	serializedData.attacks = []
	for attack in attacks:
		serializedData.attacks.append(attack.serialize())
	
	savedData.map.append(serializedData)



func deserialize(savedData):
	data = Factory.enemies.data(savedData.id)
	global_position = Vector2(savedData.global_position.x, savedData.global_position.y)
	global_rotation_degrees = savedData.global_rotation_degrees
	data.growl = savedData.growl
	init()
	for stat in data.stats: data.stats[stat].deserialize(savedData.stats[stat])
	
	statusEffects.deserialize(savedData.statusEffects)
