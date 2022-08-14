class_name Enemy extends KinematicBody2D

export(NodePath) onready var vision  = get_node(vision) as Node2D
export(NodePath) onready var lowerBodyAnimation  = get_node(lowerBodyAnimation) as AnimationPlayer
export(NodePath) onready var soundGrowl  = get_node(soundGrowl) as AudioStreamPlayer2D



var velocity: Vector2 = Vector2.ZERO
var path: Array = []
var data = {}

var opponent = null
var behavior = null setget setBehavior


func _ready():
	for stat in data.stats:
		Constants.rand.randomize()
		data.stats[stat] = Constants.rand.randi_range(data.stats[stat]*0.7, data.stats[stat])
	
	self.scale = Vector2(data.stats.size/100.0, data.stats.size/100.0)
	data.stats["move_speed"]=data.static.stats.move_speed-data.stats.size
	data.stats["health"]=data.stats.size*data.static.stats.level
	
	$Body/Lower/Animation.playback_speed=data.stats.move_speed/60
	$Sense/Collider.shape.radius = data.stats.aggression_range
	
	for ray in Globals.mapManager.spawnRays(data.stats.vision_width, data.stats.vision_height):
		ray.set_collision_mask_bit(5, true)
		ray.enabled = false
		$Vision.add_child(ray)

	
	if(global_position.distance_to(Globals.camera.global_position)>1000): 
		self.visible = false
		setEnableVission(false)
	
	setBehavior(data.behavior)
	
func _process(_delta):
	growl()

func _physics_process(delta):
	behavior.run(delta)
	if(path.size()>1): 
		look_at(path[1])
		move_and_slide(velocity*data.stats.move_speed*Constants.MOVE_SPEED_MULTIPLYER*delta)
	
	
func setEnableVission(enabled = self.visible):
	for ray in $Vision.get_children():
		ray.enabled = enabled


func hurt(dmg):
	data.stats.health-=dmg
	if(data.stats.health<1): 
		queue_free()
		Globals.mapManager.spawnDropItems(data.drops, global_position)
	else: _on_View_body_entered(null)

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
	$Body/Lower/Animation.play("run_stright")
	$bodySensor/Collider.shape.radius = data.stats.aggression_range
	$Sense/Collider.disabled = true
	setEnableVission(false)
	opponent = body


func _on_View_body_exited(_body):
	$bodySensor/Collider.shape.radius = 0
	$Sense/Collider.disabled = false
	$Body/Lower/Animation.stop()
	setEnableVission()
	path = []
	opponent = null


func _on_visibility_screen_entered():
	self.visible = true
	setEnableVission()


func _on_visibility_screen_exited():
	self.visible = false
	setEnableVission()


func _on_bodySensor_body_entered(body):
	if(!opponent and body.opponent): _on_View_body_entered(body.opponent)
