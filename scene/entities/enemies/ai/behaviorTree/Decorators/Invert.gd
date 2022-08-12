extends Task

# Invert the result

class_name Invert, "res://scene/entities/enemies/ai/behaviorTree/icons/invert.png"

func run():
	get_child(0).run()
	running()

func child_uccess():
	fail()

func child_fail():
	success()
