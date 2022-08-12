class_name Enemy extends KinematicBody2D

export(NodePath) onready var vision  = get_node(vision) as Node2D
export(NodePath) onready var lowerBodyAnimation  = get_node(lowerBodyAnimation) as AnimationPlayer

var velocity: Vector2 = Vector2.ZERO
var path: Array = []
var data = {}

var opponent = null


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


func _physics_process(delta):
	if(data.states.isChasing):
		if(path.size()>0): look_at(path[0])
		if(!data.states.isAttacking):
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

func aggressive():
	_on_View_body_entered(Globals.player)
	$Sense/Collider.disabled = true

#---------- BEHAVIOR TREE FUNCTIONS --------------#

func task_isVisible(task):	
	if(self.visible): task.succeed()
	else: task.failed()

#idle behaviors
func task_isChasing(task):
	if(data.states.isChasing): task.succeed()
	else:
		if(!data.states.isIdle): _on_View_body_exited(null)
		task.failed()
	
	
func task_checkOnView(task):
	for ray in $Vision.get_children():
		if(ray.is_colliding() and ray.get_collider().name == "Player"): 
			_on_View_body_entered(ray.get_collider())
			break
	if(data.states.isChasing): task.succeed()
	else: task.failed()


#seek behaviors
func task_generatePath(task):
	if(opponent):
		path = Globals.currentNavigation.get_simple_path(global_position, opponent.global_position, true)
		task.succeed()
	else:
		task.failed()
	
func task_navigate(task):
	if path.size() > 0:
		velocity = global_position.direction_to(path[1])
				
		if global_position == path[0]:
			path.pop_front()
			task.succeed()
		else: task.failed()
	else: task.failed()

	
func task_isNeerby(task):
	if(global_position.distance_to(opponent.global_position)<data.stats.loose_range): task.succeed()
	else: 
		if(data.states.isChasing): _on_View_body_exited(null)
		task.failed()
	

#attack behaviors
func task_isInRange(task):
	if(opponent and global_position.distance_to(opponent.global_position)<data.stats.attack_range+30):
		data.states.isAttacking = true
		$Body/Lower/Animation.stop()
		task.succeed()
	else: 
		data.states.isAttacking = false
		task.failed()
	



#---------- CONNECT FUNCTIONS --------------#

func _on_View_body_entered(body):
	$Body/Lower/Animation.play("run_stright")
	$bodySensor/Collider.shape.radius = 40
	setEnableVission(false)
	data.states.isChasing = true
	data.states.isIdle = false
	opponent = body


func _on_View_body_exited(_body):
	$bodySensor/Collider.shape.radius = 0
	$Body/Lower/Animation.stop()
	setEnableVission()
	data.states.isChasing = false
	data.states.isIdle = true


func _on_visibility_screen_entered():
	self.visible = true
	setEnableVission()


func _on_visibility_screen_exited():
	self.visible = false
	setEnableVission()


func _on_bodySensor_body_entered(body):
	if(!opponent and body.opponent): _on_View_body_entered(body.opponent)
