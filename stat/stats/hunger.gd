class_name HungerStat extends Stat

var healthModifier = Factory.statsModifiers.create("subtruct", 0)

func init(_name, _val, _agent):
	.init(_name, _val, _agent)

func run(delta):
	if(val<=0):
		healthModifier.val = delta*agent.data.stats.hunger_tolerance.val
		if agent.data.stats.health.setVal(healthModifier): agent.dead()
	else: val-=delta

func serialize(script = "hunger"):
	return .serialize(script)
