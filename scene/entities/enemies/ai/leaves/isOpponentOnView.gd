extends Leaf

class_name isOpponentOnView

func run(_delta):
	for ray in agent.vision.get_children():
		if(ray.is_colliding() and ray.get_collider().name == "Player"): 
			agent._on_View_body_entered(ray.get_collider())
			return success()
