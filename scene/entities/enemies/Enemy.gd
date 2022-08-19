class_name Enemy extends Entity

export(NodePath) onready var vision  = get_node(vision) as Node2D
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
export(NodePath) onready var sense  = get_node(sense) as CollisionShape2D
export(NodePath) onready var blockerSensor  = get_node(blockerSensor) as CollisionShape2D
export(NodePath) onready var soundGrowl  = get_node(soundGrowl) as AudioStreamPlayer2D
export(NodePath) onready var hitBox  = get_node(hitBox) as Area2D

var body = null

var path: Array = []
var velocity: Vector2 = Vector2.ZERO

var blocker = null
var opponent = []
var behavior = null setget setBehavior

var attacks = []
var curAttack = null


func _ready():
	add_child(body)
	
	.ready()
	soundGrowl.stream = data.growl
	
	if(global_position.distance_to(Globals.camera.global_position)>Constants.WIDTH): 
		visible = false
		setEnableVission(false)
	
	setBehavior(data.behavior)
	
	

func _physics_process(delta):
	process(delta)
	velocity = move_and_slide((applyedForce+velocity)*delta)
	
	
func process(delta):
	behavior.run(delta)
	
	if path.size() > 0:
		velocity = global_position.direction_to(path[0]).normalized() * data.stats.move_speed.val*Constants.MOVE_SPEED_MULTIPLYER
		
		look_at(path[0])
		
		if global_position.distance_to(path[0])<10:
			path.pop_front()
			
	growl()
	._process(delta)

	
func setEnableVission(enabled = self.visible):
	for ray in $Vision.get_children():
		ray.enabled = enabled


func hurt(opponent, dmg):
	if !._hurt(dmg):
		_on_View_body_entered(opponent)
		return false
	Globals.mapManager.spawnDropItems(data.drops, global_position)
	return true
	
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


#---------- CONNECT FUNCTIONS --------------#

func _on_View_body_entered(body):
	chooseAttack()
	$bodySensor/Collider.shape.radius = data.stats.aggression_range.val
	$Sense/Collider.disabled = true
	setEnableVission(false)
	opponent = [body]


func _on_View_body_exited(_body):
	$bodySensor/Collider.shape.radius = 0
	$Sense/Collider.disabled = false
	$Body/Lower/Animation.stop()
	setEnableVission()
	path = []
	opponent = []


func _on_visibility_screen_entered():
	self.visible = true
	setEnableVission()


func _on_visibility_screen_exited():
	self.visible = false
	if opponent.empty():
		$visibility.process_parent = true
		$visibility.physics_process_parent = true
	else:
		$visibility.process_parent = false
		$visibility.physics_process_parent = false
	setEnableVission()


func _on_bodySensor_body_entered(body):
	if(!opponent.empty() and body.opponent.empty()): body._on_View_body_entered(opponent[0])


func _on_BlockerSensor_body_entered(body):
	blocker = body

