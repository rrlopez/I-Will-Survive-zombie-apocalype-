class_name SetModifier extends Resource

var val
var type

func _init(_val, _type=null):
	val = _val
	type = _type

func execute(_value, amount = val):
	return amount

func serialize():
	return { "script": "set", "val": val, "type": type}
