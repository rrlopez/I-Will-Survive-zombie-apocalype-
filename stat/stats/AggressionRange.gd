class_name AggressionRangeStat extends Stat

func init(data, _agent):
	initValues(data, _agent)
	update()

func recompute():
	.recompute()
	update()
	
func update():
	agent.sense.shape.radius = val
	agent.blockerSensor.shape.radius = val

	
func deserialize(savedData):
	.deserialize(savedData)
	update()
