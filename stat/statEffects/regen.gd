class_name Regen extends Resource

var data = {}
var timer = 0
var rateTimer = 0

func init(_data, _opponent, _parent):
	data = _data
	reset()
	for i in data.modifiers.size():
		var modifier = data.modifiers[i]
		data.modifiers[i] = Factory.statsModifiers.create(modifier.script, modifier.val, modifier.type)
		
func run(agent, delta):
	if(rateTimer>data.rate):
		rateTimer=0
		for modifier in data.modifiers:
			Utils.getProp(agent, modifier.type).setVal(modifier)
	
	if(timer>data.duration):
		return true
	timer+=delta
	rateTimer+=delta
	return false

func reset():
	timer = 0
	rateTimer = 0

func serialize():
	var modifierObject = []
	for modifier in data.modifiers: modifierObject.append(modifier.serialize())
	return {
		"script": "regen",
		"data": {
			"duration": data.duration,
			"rate": data.rate,
			"modifiers": modifierObject
		},
		"timer": timer,
		"rateTimer": rateTimer
	}

func deserialize(savedData): 
	data = savedData.data
	timer = savedData.timer
	rateTimer = savedData.rateTimer
