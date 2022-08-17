class_name Regen extends Resource

var data = {}
var timer = 0
var rateTimer = 0

func _init(_data, opponent, parent):
	data = _data
	timer = 0
	for i in data.modifiers.size():
		var modifier = data.modifiers[i]
		data.modifiers[i] = Factory.statsModifiers.create(modifier.script, modifier.val, modifier.type)
		
func run(agent, delta):
	if(rateTimer>data.rate):
		rateTimer=0
		for modifier in data.modifiers:
			agent.data.stats[modifier.type].setVal(modifier)
	
	if(timer>data.duration):
		agent.statusEffects.erase(self)
	timer+=delta
	rateTimer+=delta

