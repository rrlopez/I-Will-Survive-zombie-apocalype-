extends Task

# Only reports a failure

class_name UntilFail, "../icons/until-fail.png"

func run(delta):
	get_child(0).run(delta)
	running()

# Ignore child uccess
func child_success():
	pass

func child_fail():
	success()
