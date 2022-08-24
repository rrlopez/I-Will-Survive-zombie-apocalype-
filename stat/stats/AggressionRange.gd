class_name AggressionRangeStat extends Stat

func init(_name, _val, _agent):
	.init(_name, _val, _agent)
	update()

func recompute():
	.recompute()
	update()
	
func update():
	agent.sense.shape.radius = val
	agent.blockerSensor.shape.radius = val


func serialize(script = "aggressionRange"):
	return .serialize(script)
