class_name DivideModifier extends Resource

var val
var type

func _init(_val, _type=null):
	val = _val
	type = _type

func execute(value, amount = val):
	return value/amount


func serialize():
	return { "script": "devide", "val": val, "type": type}
