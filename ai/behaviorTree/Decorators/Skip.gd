extends Task

class_name Skip, "../icons/limit.png"

export(int) var skipTime = 0.5
var timer = 0

func run(delta):
	timer+=delta
	if timer>=skipTime: 
		get_child(0).run(delta)
		running()
	else: success()

func child_success():
	timer = 0
	success()

func child_fail():
	fail()
	
func start(agent):
	timer = skipTime
	.start(agent)

func cancel():
	timer = skipTime
	.cancel()
