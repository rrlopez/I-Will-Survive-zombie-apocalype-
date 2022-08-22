class_name HealthStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func setVal(modifier):
	.setVal(modifier)
	agent.healthStatCallback(self)
	return val<1
	
func reset():
	.reset()
	agent.healthStatCallback(self)
