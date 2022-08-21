class_name HungerStat extends Stat

var healthModifier = Factory.statsModifiers.create("subtruct", 0)

func _init(_name, _val, _agent):
	init(_name, _val, _agent)

func run(delta):
	if(val<1):
		healthModifier.val = delta*agent.data.stats.hunger_tolerance.val
		agent.data.stats.health.setVal(healthModifier)
	else: val-=delta
