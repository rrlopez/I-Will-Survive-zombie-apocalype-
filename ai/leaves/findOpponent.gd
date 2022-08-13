extends Leaf

class_name findOpponent

func run(_delta):
	agent._on_View_body_entered(Globals.player)
	success()
