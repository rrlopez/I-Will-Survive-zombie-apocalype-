class_name ItemFactory extends Node


var itemClasses = {
	"resource": ResourceItem,
	"consumable": ConsumableItem,
	"placable": PlacableItem,
	"weapon": EquipmentItem,
}

var placeholders = {
	"weapon": load("res://scene/ui/inventory/sprites/weapon_placeholder.png"),
	"hand": load("res://scene/ui/inventory/sprites/hand_placeholder.png"),
	"armor": load("res://scene/ui/inventory/sprites/armor_placeholder.png"),
	"tool": load("res://scene/ui/inventory/sprites/tool_placeholder.png"),
}


var items = {}
var itemTexture = {}
var itemObjectTexture = {}

func _init():
	for item in Utils.import_data("res://data/items.json"):
		itemTexture[item.static_data.id] = load("res://scene/ui/items/sprites/"+item.static_data.id+".png")
		itemObjectTexture[item.static_data.id] = load("res://assets/entities/"+item.static_data.id+".png")
		items[item.static_data.id] = item
	
	
func data(name):
	var data = {"static": items[name].static_data}
	data.quantity = 0
	if items[name].has("dynamic_data"):
		var dynamicData = items[name].dynamic_data.duplicate(true)
		for key in dynamicData.keys():
			data[key] = dynamicData[key]
	return data	
	
	
func create(name, data=data(name)):
	var item = itemClasses[data.static.type].new()
	item.init()
	return item

func deserialize(data):
	var item = itemClasses[data.static.type].new()
	item.deserialize(data)
	return item
