class_name AggressionRangeStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)
	update()

func setVal(modifier):
	.setVal(modifier)
	update()

func update():
	agent.sense.shape.radius = val
	agent.blockerSensor.shape.radius = val
