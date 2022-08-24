class_name PopModifier extends Resource

var id
var type

func _init(_id, _type=null):
	id = _id
	type = _type

func execute(array, _id = id):
	for element in array.val:
		if element.data.id == _id: 
			array.remove(element)


func serialize():
	return { "script": "pop", "val": id, "type": type}
