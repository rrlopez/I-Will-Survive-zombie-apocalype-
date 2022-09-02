class_name MultiplyModifier extends Resource

var name
var val
var type

func _init(_val, _type=null):
	name = _val.name
	val = _val.amount
	type = _type

func execute(value, amount = val):
	return value*amount

func getInfo():
	var symbol = "-"
	if(val>1): symbol = "+"
	
	return{
		"labelType": 0,
		"icon": load("res://assets/statsIcon/"+name+".png"), 
		"value": symbol+String(abs(val-1)*100)+"%",
		"symbol": symbol
	}
	
func serialize():
	return { "script": "multiply", "val": {"name": name, "amount":val}, "type": type}
	
func deserialize(savedData):
	val = savedData.val
	type = savedData.type


