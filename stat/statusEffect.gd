class_name StatusEffect extends Resource

var data = {}

func _init(_data):
	data = _data
	
func run(agent, delta):
	for effect in data.effects: 
		if effect.run(agent, delta): data.effects.erase(effect)
	if data.effects.empty(): 
		agent.removeStatusEffect(self)
		return true
	return false
	
func reset():
	for effect in data.effects: effect.reset()

func remove():
	for effect in data.effects: 
		effect.data.duration = 0
