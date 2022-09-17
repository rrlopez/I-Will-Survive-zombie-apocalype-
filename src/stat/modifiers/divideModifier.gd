class_name DivideModifier extends Resource

var name
var val
var type

func _init(_val, _type=null):
	name = _val.name
	val = _val.amount
	type = _type

func execute(value, amount = val):
	return value/amount
	
func getInfo():
	return{
		"labelType": 0,
		"icon": load("res://assets/statsIcon/"+name+".png"), 
		"value": "-"+String(100/2)+"%",
		"symbol": "-"
	}

func serialize():
	return { "script": "devide", "val": {"name": name, "amount":val}, "type": type}
	
func deserialize(savedData):
	val = savedData.val
	type = savedData.type
