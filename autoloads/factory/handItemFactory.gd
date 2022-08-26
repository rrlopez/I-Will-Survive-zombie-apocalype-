class_name HandItemFactory extends Node

var handItems = {
	"torch": preload("res://scene/entities/items/handItems/torch.tscn")
}

	
func create(parent, data):
	var handItem = handItems[data.static.script].instance()
	handItem.init(parent, data)
	return handItem

func deserialize(parent, data):
	var handItem = handItems[data.static.script].instance()
	handItem.deserialize(parent, data)
	return handItem
