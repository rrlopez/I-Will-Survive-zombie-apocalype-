class_name ApplyForce extends Resource

var defaultForce = Vector2.ZERO
var force = Vector2.ZERO
var friction = 1

func _init(data, opponent, parent):
	var direction = parent.global_position.direction_to(opponent.global_position)
	force = direction*data.force*100
	defaultForce = force
	friction = data.friction

func run(agent, _delta):
	if(force.length()<1):
		agent.applyedForce = Vector2.ZERO
		return true
	agent.applyedForce+=force
	force*=friction
	return false

func reset():
	force = defaultForce
