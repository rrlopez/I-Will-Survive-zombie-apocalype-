extends Leaf

class_name isOpponentOnView

func run():
	for ray in agent.vision.get_children():
		if(ray.is_colliding() and ray.get_collider().name == "Player"): 
			_on_View_body_entered(ray.get_collider())
			break
	if(agent.data.states.isChasing): success()
	else: fail()
