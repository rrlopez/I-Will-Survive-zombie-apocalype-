class_name Buff extends Resource

var data = {}
var timer = 0

func _init(_data, opponent, _parent):
	data = _data
	reset()
	for i in data.modifiers.size():
		var modifier = data.modifiers[i]
		data.modifiers[i] = Factory.statsModifiers.create(modifier.script, modifier.val, modifier.type)
		
		Utils.getProp(opponent, data.modifiers[i].type).addModifier(data.modifiers[i])

func run(agent, delta):
	if(timer>data.duration):
		for modifier in data.modifiers:
			Utils.getProp(agent, modifier.type).removeModifier(modifier)
		return true
	timer+=delta
	return false


func reset():
	timer = 0
