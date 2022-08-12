extends Task

# Only reports a success

class_name UntilSucces, "res://scene/entities/enemies/ai/behaviorTree/icons/until-success.png"

func run():
	get_child(0).run()
	running()

func child_success():
	success()

# Ignore child failure
func child_fail():
	pass
