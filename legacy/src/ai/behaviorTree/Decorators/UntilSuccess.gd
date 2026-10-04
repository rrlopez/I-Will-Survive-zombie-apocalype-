extends Task

# Only reports a success

class_name UntilSucces, "../icons/until-success.png"

func run(delta):
	get_child(0).run(delta)
	running()

func child_success():
	success()

# Ignore child failure
func child_fail():
	pass
