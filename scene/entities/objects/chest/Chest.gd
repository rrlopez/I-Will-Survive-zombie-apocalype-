extends StaticBody2D

export(int) var size = 1
export(String) var inventory_name

var inventory:Inventory

var data = {
	"size": size,
	"name": inventory_name,
	"slot_type": "loot_slot",
	"slot_scene_type": "loot_slot",
	"items": [
		{ "name": "machette", "quantity": 1},
		{ "name": "AMT AutoMag III", "quantity": 1},
		{ "name": "m13", "quantity": 1},
		{ "name": "m14", "quantity": 1},
		{ "name": "crafting table", "quantity": 1},
	]
}
	
func _ready():
	data.size = size
	data.name = inventory_name
	inventory = Utils.createInventory(data)
	


func _on_Area_body_entered(_body):
	Globals.inventoryManager.show()
	Globals.HUD.craftPanel.hide()
	Globals.HUD.lootPanel.add_inventory(inventory)
	Globals.HUD.hotbar.rect_position = Vector2(350, 29)

func _on_Area_body_exited(_body):
	Globals.HUD.hotbar.rect_position = Vector2(610, 12)
	Globals.HUD.lootPanel.remove_inventory(inventory)
	Globals.inventoryManager.hide()
