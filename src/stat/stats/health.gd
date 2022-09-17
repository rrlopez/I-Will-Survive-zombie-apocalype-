class_name HealthStat extends Stat

func init(data, _agent):
	initValues(data, _agent)

func setVal(modifier):
	.setVal(modifier)
	agent.healthStatCallback(self)
	return val<1
	
func reset():
	.reset()
	agent.healthStatCallback(self)
