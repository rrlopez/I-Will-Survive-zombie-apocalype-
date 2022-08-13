extends Leaf

class_name hasOpponent

func run(_delta):
	if agent.opponent: success()
	else: fail()
