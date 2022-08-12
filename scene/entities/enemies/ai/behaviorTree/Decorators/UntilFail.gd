extends Task

# Only reports a failure

class_name UntilFail, "res://scene/entities/enemies/ai/behaviorTree/icons/until-fail.png"

func run():
	get_child(0).run()
	running()

# Ignore child uccess
func child_success():
	pass

func child_fail():
	success()
