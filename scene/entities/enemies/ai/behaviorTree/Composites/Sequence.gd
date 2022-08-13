extends Task

# All children must run successfully

class_name Sequence, "res://scene/entities/enemies/ai/behaviorTree/icons/sequence.png"

var current_child = 0

func run(delta):
	get_child(current_child).run(delta)
	running()

func child_success():
	current_child += 1
	if current_child >= get_child_count():
		current_child = 0
		success()

func child_fail():
	current_child = 0
	fail()

func cancel():
	current_child = 0
	.cancel()

func start(agent):
	current_child = 0
	.start(agent)
