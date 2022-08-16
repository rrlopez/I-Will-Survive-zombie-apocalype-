class_name ApplyForce extends Resource

var force = Vector2.ZERO
var friction = 1

func _init(data):
	force = data.direction*data.force
	friction = data.friction

func run(agent):
	if(force.length()<1):
		agent.statusEffects.erase(self)
		agent.applyedForce = Vector2.ZERO
		return
	agent.applyedForce+=force
	force*=friction

