class_name PushModifier extends Resource

var element
var type

func _init(_element, _type=null):
	element = _element
	type = _type

func execute(_array, _element = element):
	Factory.statusEffects.create(_element.duplicate(true))

func getInfo():
	var effects = []
	
	for effect in element.effects.duplicate(true): 
		var e = Factory.statusEffects.statusEffects[effect.script].new()
		e.init(effect.stats)
		for info in e.getInfo():
			effects.append(info)
			
	return{
		"labelType": 1,
		"name": element.name,
		"value": String(element.chance)+"%",
		"effects": effects,
		"symbol": ""
	}

func serialize():
	return { "script": "push", "val": element, "type": type}

	
func deserialize(savedData):
	element = savedData.val
	type = savedData.type
