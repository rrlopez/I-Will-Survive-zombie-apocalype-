extends Leaf

class_name hasOpponent

func run(_delta):
	if agent.opponent.empty(): fail()
	else: success()
