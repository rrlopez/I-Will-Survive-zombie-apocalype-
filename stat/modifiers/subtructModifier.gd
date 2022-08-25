class_name SubtructModifier extends Resource

var val
var type

func _init(_val, _type=null):
	val = _val
	type = _type

func execute(value, amount = val):
	return value-amount

func serialize():
	return { "script": "subtruct", "val": val, "type": type}

	
func deserialize(savedData):
	val = savedData.val
	type = savedData.type
