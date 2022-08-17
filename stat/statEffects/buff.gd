class_name Buff extends Resource

var data = {}
var timer = 0

func _init(_data, opponent, parent):
	data = _data
	timer = 0
	for modifier in data.modifiers:
		opponent.data.stats[modifier.type].addModifier(modifier)

func run(agent, delta):
	if(timer>data.duration):
		agent.statusEffects.erase(self)
		for modifier in data.modifiers:
			agent.data.stats[modifier.type].removeModifier(modifier)
	timer+=delta

