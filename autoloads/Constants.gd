extends Node

var WIDTH = ProjectSettings.get_setting("display/window/size/width")
var HEIGHT = ProjectSettings.get_setting("display/window/size/height")

const MOVE_SPEED_MULTIPLYER = 100
const ANGLE_BETWEEN_RAYS = deg2rad(5)

var rand = RandomNumberGenerator.new()


var enemies = load_enemies()
func load_enemies():
	var _enemies = {}
	for enemy in Utils.import_data("res://scene/entities/enemies/data/data.json"):
		_enemies[enemy.static_data.id] = enemy
	return _enemies
func get_enemies(name):
	var data = {
		"static": enemies[name].static_data,
		"states": {
			"isChasing": false,
			"isAttacking": false,
			"isIdle": false,
			"isDead": false
		}
	}
	if enemies[name].has("dynamic_data"):
		var dynamicData = enemies[name].dynamic_data.duplicate(true)
		for key in dynamicData.keys():
			data[key] = dynamicData[key]
	return data


var items = load_items()
func load_items():
	var _items = {}
	for item in Utils.import_data("res://scene/ui/items/data/items.json"):
		item.static_data["texture"] = load("res://scene/ui/items/sprites/"+item.static_data.id+".png")
		item.static_data["object_texture"] = load("res://assets/entities/"+item.static_data.id+".png")
		_items[item.static_data.id] = item
	return _items
func get_item(name):
	var data = {"static": items[name].static_data}
	data.quantity = 0
	if items[name].has("dynamic_data"):
		var dynamicData = items[name].dynamic_data.duplicate()
		for key in dynamicData.keys():
			data[key] = dynamicData[key]
	return data
	
	
var itemClasses = {
	"resource": ResourceItem,
	"consumable": ConsumableItem,
	"placable": PlacableItem,
	"weapon": EquipmentItem,
}


var weapons = {
	"pistol": preload("res://scene/entities/items/weapons/range/Pistol.tscn"),
	"riffle": preload("res://scene/entities/items/weapons/range/Riffle.tscn")
}

var placesables = {
	"table": preload("res://scene/entities/objects/table/Table.tscn")
}



var fonts = {
	8:preload("res://font/font_8.tres"),
	16:preload("res://font/font_16.tres")
}

var placeholders = {
	"weapon": load("res://scene/ui/inventory/sprites/weapon_placeholder.png"),
	"hand": load("res://scene/ui/inventory/sprites/hand_placeholder.png"),
	"armor": load("res://scene/ui/inventory/sprites/armor_placeholder.png"),
	"tool": load("res://scene/ui/inventory/sprites/tool_placeholder.png"),
}

var slotScene = {
	"slot": preload("res://scene/ui/inventory/Slot.tscn"),
	"equipment_slot": preload("res://scene/ui/inventory/Equipment_slot.tscn"),
	"loot_slot": preload("res://scene/ui/inventory/Loot_slot.tscn")
}

var vehicle_controllerScene = preload("res://scene/entities/vehicles/Controller.tscn")
var player_controllerScene = preload("res://scene/entities/player/controller/Controller.tscn")


