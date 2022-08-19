class_name HealthStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func setVal(modifier):
	.setVal(modifier)
	if(val<1): 
		agent.queue_free()
		return true
	return false
