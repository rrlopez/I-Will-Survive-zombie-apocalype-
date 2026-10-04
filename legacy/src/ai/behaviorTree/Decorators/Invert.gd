extends Task

# Invert the result

class_name Invert, "../icons/invert.png"

func run(delta):
	get_child(0).run(delta)
	running()

func child_success():
	fail()

func child_fail():
	success()
