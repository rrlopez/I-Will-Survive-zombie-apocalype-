class_name HungerStat extends Stat

var healthModifier = Factory.statsModifiers.create("subtruct", {"name": "Health", "amount": 0})

func init(data, _agent):
	initValues(data, _agent)

func run(delta):
	if(val<=0):
		healthModifier.val = delta*agent.data.stats.hunger_tolerance.val
		if agent.data.stats.health.setVal(healthModifier): agent.dead()
	else: val-=delta
