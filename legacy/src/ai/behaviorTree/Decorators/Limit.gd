extends Task

# Will fail if the child task succeeds and gets called again too many times

class_name Limit, "../icons/limit.png"

# Maximum number of times to run
export(int) var LIMIT = 4

var count = 0

func run(delta):
	get_child(0).run(delta)
	running()

func child_success():
	count += 1
	if count >= LIMIT:
		count = 0
		fail()
	else:
		success()

func child_fail():
	count = 0
	fail()

func start(agent):
	count = 0
	.start(agent)

func cancel():
	count = 0
	.cancel()
