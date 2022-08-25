class_name Buff extends Resource

var data = {}
var timer = 0

func init(_data, opponent, _parent):
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

func serialize():
	var modifierObject = []
	for modifier in data.modifiers: modifierObject.append(modifier.serialize())
	return {
		"script": "buff",
		"data": {
			"duration": data.duration,
			"modifiers": modifierObject
		},
		"timer":0
	}

func deserialize(savedData): 
	data = savedData.data
	for i in data.modifiers.size(): data.modifiers[i] = Factory.statsModifiers.deserialize(data.modifiers[i])
	timer = savedData.timer
