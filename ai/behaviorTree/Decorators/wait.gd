extends Task


class_name Wait, "../icons/limit.png"

export(int) var timer = 4

func run(delta):
	timer-=delta
	if timer<0: get_child(0).run(delta)
	running()

func child_success():
	timer = 0
	success()

func child_fail():
	timer = 0
	fail()

func start(agent):
	timer = 0
	.start(agent)

func cancel():
	timer = 0
	.cancel()
