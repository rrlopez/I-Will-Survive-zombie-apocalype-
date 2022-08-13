extends Task

# Run all child Tasks together in SEQUENCE or SELECTOR policy mode

class_name Parallel, "../icons/parallel.png"

enum { SEQUENCE, SELECTOR }

export(bool) var policy = SEQUENCE

var num_results = 0

func run(delta):
	for child in get_children():
		child.run(delta)
	running()

func child_success():
	num_results += 1
	if policy == bool(SEQUENCE):
		if num_results >= get_child_count():
			num_results = 0
			success()
	else:
		success()

func child_fail():
	num_results += 1
	if policy == bool(SELECTOR):
		if num_results >= get_child_count():
			num_results = 0
			fail()
	else:
		fail()

func cancel():
	num_results = 0
	.cancel()

func start(agent):
	num_results = 0
	.start(agent)
