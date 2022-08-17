class_name Enemy extends KinematicBody2D

export(NodePath) onready var vision  = get_node(vision) as Node2D
export(NodePath) onready var sense  = get_node(sense) as CollisionShape2D
export(NodePath) onready var blockerSensor  = get_node(blockerSensor) as CollisionShape2D
export(NodePath) onready var lowerBodyAnimation  = get_node(lowerBodyAnimation) as AnimationPlayer
export(NodePath) onready var soundGrowl  = get_node(soundGrowl) as AudioStreamPlayer2D

var data = {}
var statusEffects = []

var applyedForce: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var path: Array = []

var blocker = null
var opponent = []
var behavior = null setget setBehavior


func _ready():
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Factory.stats.create(stat, data.stats[stat], self)
	
	soundGrowl.stream = data.growl
	
	if(global_position.distance_to(Globals.camera.global_position)>Constants.WIDTH): 
		self.visible = false
		setEnableVission(false)
	
	setBehavior(data.behavior)
	
func _process(delta):
	behavior.run(delta)
	
	if path.size() > 0:
		velocity = global_position.direction_to(path[0]).normalized() * data.stats.move_speed.val*Constants.MOVE_SPEED_MULTIPLYER
		
		look_at(path[0])
		
		if global_position.distance_to(path[0])<10:
			path.pop_front()
	
	for statusEffect in statusEffects: statusEffect.run(self, delta)
	growl()

func _physics_process(delta):
	velocity = move_and_slide((applyedForce+velocity)*delta)
	
	
func setEnableVission(enabled = self.visible):
	for ray in $Vision.get_children():
		ray.enabled = enabled


func hurt(opponent, dmg):
	if !data.stats.health.addVal(-dmg):
		 _on_View_body_entered(opponent)

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
	setEnableVission()


func _on_bodySensor_body_entered(body):
	if(!opponent.empty() and body.opponent.empty()): body._on_View_body_entered(opponent[0])


func _on_BlockerSensor_body_entered(body):
	blocker = body
