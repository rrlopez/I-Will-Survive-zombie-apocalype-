class_name Regen extends Resource

var data = {}
var timer = 0
var rateTimer = 0

func init(_data):
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
	
	rateTimer+=delta
	
	if data.duration<0: return false
	if(timer>data.duration): return true
	timer+=delta
	return false
	
func remove(agent):
	for modifier in data.modifiers:
		Utils.getProp(agent, modifier.type).removeModifier(modifier)
		

func add(opponent, _parent=null):
	for modifier in data.modifiers:
		Utils.getProp(opponent, modifier.type).addModifier(modifier)

func reset():
	timer = 0
	rateTimer = 0


func getInfo():
	var modifiers = []
	
	for modifier in data.modifiers: 
		var info = modifier.getInfo()
		info.value = info.symbol+String(modifier.val*(60*data.rate)) + "/s"
		if data.duration>0: info.value = info.value + " in " + String(data.duration) + "s"
		modifiers.append(info)
	
	return modifiers


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

func deserialize(savedData, _agent): 
	data = savedData.data
	for i in data.modifiers.size(): data.modifiers[i] = Factory.statsModifiers.deserialize(data.modifiers[i])
	timer = savedData.timer
	rateTimer = savedData.rateTimer
	
