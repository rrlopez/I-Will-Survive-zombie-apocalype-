extends Node

onready var	inventoryScene = {
	"inventory": preload("res://scene/ui/inventory/Inventory.tscn"),
	"craft_inventory": preload("res://scene/ui/inventory/Craft_inventory.tscn")
}
onready var	itemScene = preload("res://scene/ui/items/Item.tscn")

func import_data(path):
	var file = File.new()
	file.open(path, File.READ)
	var json = JSON.parse(file.get_as_text())
	file.close()
	return json.result
	
	
func filter(list: Array, key: String) -> Array:
	var filtered: Array = []
	for element in list:
		if element.key != key:
			filtered.append(element)
	return filtered

func createInventory(data, sceneType='inventory'):
	var inventory = inventoryScene[sceneType].instance()
	inventory.size = data.size
	inventory.inventory_name = data.name
	if data.has("slot_type"): inventory.slot_type = data.slot_type
	if data.has("slot_scene_type"): inventory.slot_scene_type = data.slot_scene_type

	for itemData in data.items:
		createItem(inventory, itemData)
		
	return inventory


func createItem(inventory, data):
	var item = Factory.items.create(data.name)
	data.quantity = item.add_item_quantity(data.quantity)
	inventory.add_item(item)
	if data.quantity > 0: createItem(inventory, data)


func get_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)

	var file = dir.get_next()
	while file != '':
		if file.get_extension() != "import":
			files += [file]
		file = dir.get_next()

	return files

func findNodeDescendantsInGroup(node: Node, groupName: String) -> Array:
	var descendantsInGroup := []
	for child in node.get_children():
		if child.is_in_group(groupName):
			descendantsInGroup.append(child)
		descendantsInGroup += findNodeDescendantsInGroup(child, groupName)
	return descendantsInGroup
