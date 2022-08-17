class_name StatsModifierFactory extends Node

var modifiers = {
	'add': AddModifier,
	'subtruct': SubtructModifier,
	'multiply': MultiplyModifier,
	'divide': DivideModifier,
	'set': SetModifier,
}

func createAll(data):
	for i in data.size():
		data[i] = create(data[i].script, data[i].val)
	
func create(script, val, type=null):
	return modifiers[script].new(val, type)
	
