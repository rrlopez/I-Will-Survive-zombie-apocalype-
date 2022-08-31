class_name Buff extends Resource

var data = {}
var timer = 0

func init(_data):
	data = _data
	reset()
	for i in data.modifiers.size():
		var modifier = data.modifiers[i]
		data.modifiers[i] = Factory.statsModifiers.create(modifier.script, modifier.val, modifier.type)


func run(agent, delta):
	if data.duration<0: return false
	if(timer>data.duration):
		remove(agent)
		return true
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
	
	
func getInfo():
	var modifiers = []
	
	for modifier in data.modifiers: 
		var info = modifier.getInfo()
		if data.duration>0: info.value = info.value + " in " + String(data.duration) + "s"
		modifiers.append(info)
	
	return modifiers


func serialize():
	var modifierObject = []
	for modifier in data.modifiers: modifierObject.append(modifier.serialize())
	return {
		"script": "buff",
		"data": {
			"duration": data.duration,
			"modifiers": modifierObject
		},
		"timer": timer
	}

func deserialize(savedData, agent):
	init(savedData.data)
	add(agent)
	timer = savedData.timer
