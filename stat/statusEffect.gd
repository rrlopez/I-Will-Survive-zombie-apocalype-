class_name StatusEffect extends Resource

var data = {}

func _init(_data):
	data = _data
	
func run(agent, delta):
	for effect in data.effects: effect.run(agent, delta)
