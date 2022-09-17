class_name PopModifier extends Resource

var icon
var name
var id
var type

func _init(_val, _type=null):
	name = _val.name
	id = _val.id
	icon = _val.icon
	type = _type

func execute(array, _id = id):
	for element in array.val:
		if element.data.id == _id: 
			array.remove(element)

func getInfo():
	return{
		"labelType": 2,
		"icon": icon,
		"symbol": ""
	}


func serialize():
	return { "script": "pop", "val": id, "type": type}

	
func deserialize(savedData):
	id = savedData.val
	type = savedData.type
