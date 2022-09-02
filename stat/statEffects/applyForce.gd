class_name ApplyForce extends Resource

var defaultForce = Vector2.ZERO
var force = Vector2.ZERO
var friction = 1

func init(data):
	force = data.force*100
	friction = data.friction

func run(agent, _delta):
	if(force.length()<1):
		agent.applyedForce = Vector2.ZERO
		force = Vector2.ZERO
		return true
	agent.applyedForce+=force
	force*=friction
	return false
	
func remove(_agent):
	pass
		

func add(opponent, parent):
	var direction = parent.global_position.direction_to(opponent.global_position)
	force = direction*force
	defaultForce = force

func reset():
	force = defaultForce


func getInfo():
	return [{
		"labelType": 2,
		"icon": load("res://assets/statusEffectIcons/wounded.png"),
		"value": String(force)
	}]

func serialize():
	return {
		"script": "applyForce",
		"defaultForce": {"x": defaultForce.x, "y": defaultForce.y},
		"force": {"x": force.x, "y": force.y},
		"friction": friction
	}

func deserialize(savedData, _agent): 
	defaultForce = Vector2(savedData.defaultForce.x, savedData.defaultForce.y)
	force = Vector2(savedData.force.x, savedData.force.y)
	friction = savedData.friction
