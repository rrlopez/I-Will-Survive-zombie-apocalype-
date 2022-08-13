extends Task

# All randomly selected children must succeed

class_name RandomSequence, "res://scene/entities/enemies/ai/behaviorTree/icons/random-sequence.png"

var sequence
var idx = 0

func _ready():
	set_sequence()

func set_sequence():
	idx = 0
	sequence = range(get_child_count())
	sequence.shuffle()

func run(delta):
	get_child(sequence[idx]).run(delta)
	running()

func child_fail():
	set_sequence()
	fail()

func child_success():
	idx += 1
	if idx >= sequence.size():
		set_sequence()
		success()

func cancel():
	idx = 0
	.cancel()

func start(agent):
	idx = 0
	.start(agent)
