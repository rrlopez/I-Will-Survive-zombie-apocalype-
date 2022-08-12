extends Task

# See Test/Leaves/*.gd for example code
class_name Leaf

var agent = null

# Non-final non-abstact methods
func start(_agent):
	agent = _agent

func run():
	pass
