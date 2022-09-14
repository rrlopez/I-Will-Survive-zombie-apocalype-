extends KinematicBody2D

var accelerating = false
var isMaunted = false
var breaking = false

var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var steer_angle = 0
var turn = 0

var controller
var passanger

var data = {
	"stats":{
		"size": 30
	},
	"engine_power": 3000,
	"friction": 0.9,
	"drag": 0.0015,
	"break_power": 450,
	"max_speed_reverse": 250,
	"wheel_base": 200,
	"steering_angle": 15,
	"slip_speed": 15,
	"traction_fast": 0.1,
	"traction_slow": 0.7,
}

func _ready():
	controller = Constants.vehicle_controllerScene.instance()
	controller.connect("use_disembark", self, "_on_Controller_use_disembark")
	controller.connect("use_accelerate", self, "_on_Controller_use_accelerate")
	controller.connect("use_break", self, "_on_Controller_use_break")
	controller.connect("use_rotateArea_degrees", self, "_on_Controller_use_rotateArea_degrees")
	controller.connect("use_rotateArea_released", self, "_on_Controller_use_rotateArea_released")
	
	
	
func _physics_process(delta):
	if(isMaunted || velocity.length()>0):
		acceleration = Vector2.ZERO
		get_input()
		apply_friction()
		calculate_steering(delta)
		velocity += acceleration * delta
		if(isMaunted): passanger.global_position = global_position
		elif(passanger): passanger.move_and_slide(velocity/3)
		velocity = move_and_slide(velocity)


func get_input():
	#turn = 0
	#if Input.is_action_pressed("ui_right"):
	#	turn += 1
	#if Input.is_action_pressed("ui_left"):
	#	turn -= 1
	steer_angle = turn * deg2rad(data.steering_angle)
	if accelerating: acceleration = transform.x * data.engine_power
	if breaking: acceleration = transform.x * -data.break_power


func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
		if(!isMaunted): passanger = null
	var friction_force = velocity * -data.friction
	var drag_force = velocity * velocity.length() * -data.drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force
		
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * data.wheel_base / 2.0
	var front_wheel = position + transform.x * data.wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = data.traction_slow
	if velocity.length() > data.slip_speed:
		traction = data.traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), data.max_speed_reverse)
	rotation = new_heading.angle()
	
	
func addCamera():
	isMaunted=true
	var cameraParent = Globals.camera.get_parent()
	if(cameraParent): cameraParent.remove_child(Globals.camera)
	var zoom = 3
	Globals.camera.zoom = Vector2(zoom, zoom)
	Globals.camera.rotation_degrees = 90
	Globals.camera.position = Vector2(0, zoom*-180).rotated(deg2rad(90))
	add_child(Globals.camera)


func _on_Door_body_entered(body):
	passanger = body
	passanger.global_position = global_position
	passanger._on_Player_tree_exited()
	Globals.currentController = controller
	addCamera()


func _on_Controller_use_disembark():
	isMaunted=false
	passanger.addCamera()
	passanger.global_position = $disembarkPosition.global_position
	yield(get_tree(),"idle_frame")
	passanger._on_player_tree_entered()
	Globals.currentController = passanger.controller
	_on_Controller_use_accelerate(false)
	_on_Controller_use_break(false)


func _on_Controller_use_rotateArea_degrees(degrees):
	if(degrees<1): turn = min(degrees/100 , 1)
	else: turn = max(degrees/100, -1)


func _on_Controller_use_rotateArea_released():
	steer_angle = 0
	turn = 0


func _on_Controller_use_accelerate(value):
	accelerating = value


func _on_Controller_use_break(value):
	breaking = value


func hurt(_opponen, _dmg):
	pass


func _on_Bumper_body_entered(_body):
	pass # Replace with function body.


func _on_area_area_entered(_area):
	if velocity.length()>1:
		var parent = self.get_parent()
		parent.remove_child(self)
		Globals.mapManager.add_child(self)
		position = position + parent.global_position
		$area.disconnect("area_entered", self, "_on_area_area_entered")
