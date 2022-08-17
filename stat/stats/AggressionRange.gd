class_name AggressionRangeStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	addVal(val)

func addVal(amout):
	.addVal(amout)
	agent.sense.shape.radius = val
	agent.blockerSensor.shape.radius = val
