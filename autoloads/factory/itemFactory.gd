class_name ItemFactory extends Node


var itemClasses = {
	"resource": ResourceItem,
	"consumable": ConsumableItem,
	"placable": PlacableItem,
	"equipment": EquipmentItem,
}

var placeholders = {
	"weapon": load("res://scene/ui/inventory/sprites/weapon_placeholder.png"),
	"hand": load("res://scene/ui/inventory/sprites/hand_placeholder.png"),
	"armor": load("res://scene/ui/inventory/sprites/armor_placeholder.png"),
	"tool": load("res://scene/ui/inventory/sprites/tool_placeholder.png"),
}


var dynamicData = {}
var staticData = {}
var itemTexture = {}
var itemObjectTexture = {}

func _init():
	for item in Utils.import_data("res://data/items.json"):
		itemTexture[item.static_data.id] = load("res://scene/ui/items/sprites/"+item.static_data.id+".png")
		itemObjectTexture[item.static_data.id] = load("res://assets/entities/"+item.static_data.id+".png")
		staticData[item.static_data.id] = item.static_data
		dynamicData[item.static_data.id] = {}
		if item.has("dynamic_data"): dynamicData[item.static_data.id] = item.dynamic_data
		dynamicData[item.static_data.id]["id"] = item.static_data.id
	
	
	
func create(id, quantity = 0):
	var data = dynamicData[id].duplicate(true)
	data.quantity = quantity
	var item = itemClasses[staticData[id].type].new()
	item.init(data, staticData[id])
	return item

func deserialize(data):
	var item = create(data.id)
	item.deserialize(data)
	return item
