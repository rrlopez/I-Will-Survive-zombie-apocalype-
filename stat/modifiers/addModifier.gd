class_name AddModifier extends Resource

var val
var type

func _init(_val, _type=null):
	val = _val
	type = _type

func execute(value, amount = val):
	return value+amount


func serialize():
	return { "script": "add", "val": val, "type": type}
