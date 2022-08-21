class_name HungerStat extends Stat

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func setVal(modifier):
	if(val<1): 
		modifier.val *= agent.data.stats.hunger_tolerance.val
		agent.data.stats.health.setVal(modifier)
	else: .setVal(modifier)
