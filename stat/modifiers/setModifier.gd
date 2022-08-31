class_name SetModifier extends Resource

var name
var val
var type

func _init(_val, _type=null):
	name = _val.name
	val = _val.amount
	type = _type

func execute(_value, amount = val):
	return amount
	
func getInfo():
	return{
		"labelType": 0,
		"icon": load("res://assets/statsIcon/"+name+".png"), 
		"value": "="+String(val),
		"symbol": "="
	}

func serialize():
	return { "script": "set", "val": val, "type": type}

	
func deserialize(savedData):
	val = savedData.val
	type = savedData.type
