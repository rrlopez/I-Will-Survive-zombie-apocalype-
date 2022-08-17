class_name ApplyForce extends Resource

var force = Vector2.ZERO
var friction = 1

func _init(data, opponent, parent):
	var direction = parent.global_position.direction_to(opponent.global_position)
	force = direction*data.force*100
	friction = data.friction

func run(agent):
	if(force.length()<1):
		agent.statusEffects.erase(self)
		agent.applyedForce = Vector2.ZERO
		return
	agent.applyedForce+=force
	force*=friction

